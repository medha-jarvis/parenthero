import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as cors from 'cors';
import * as path from 'path';
import * as os from 'os';
import * as fs from 'fs';
import * as crypto from 'crypto';

const PDFDocument = require('pdfkit');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();
const storage = admin.storage();
const messaging = admin.messaging();

// Stripe configuration
const stripeSecret = functions.config().stripe?.secret || process.env.STRIPE_SECRET || '';
const stripeWebhookSecret = functions.config().stripe?.webhook_secret || process.env.STRIPE_WEBHOOK_SECRET || '';
const stripe = require('stripe')(stripeSecret);

// Razorpay configuration
const razorpayKeyId = functions.config().razorpay?.key_id || process.env.RAZORPAY_KEY_ID || '';
const razorpayKeySecret = functions.config().razorpay?.key_secret || process.env.RAZORPAY_KEY_SECRET || '';
const Razorpay = require('razorpay');
const razorpay = new Razorpay({
  key_id: razorpayKeyId,
  key_secret: razorpayKeySecret,
});

// CORS middleware
const corsHandler = cors({ origin: true });

// ================================================================
// STRIPE SUBSCRIPTION
// ================================================================

/**
 * Creates a Stripe Checkout Session for subscription
 * Expects: { userId, priceId, successUrl, cancelUrl, customerEmail }
 */
export const createStripeSubscription = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to create a subscription'
    );
  }

  const { priceId, successUrl, cancelUrl, customerEmail } = data;
  const userId = context.auth.uid;

  if (!priceId || !successUrl || !cancelUrl) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: priceId, successUrl, cancelUrl'
    );
  }

  try {
    // Create or retrieve Stripe customer
    let customerId: string;
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();

    if (userData?.stripeCustomerId) {
      customerId = userData.stripeCustomerId;
    } else {
      const customer = await stripe.customers.create({
        email: customerEmail || userData?.email || '',
        metadata: { firebaseUid: userId },
      });
      customerId = customer.id;
      await db.collection('users').doc(userId).update({
        stripeCustomerId: customerId,
      });
    }

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      payment_method_types: ['card'],
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: {
        firebaseUid: userId,
      },
      subscription_data: {
        metadata: {
          firebaseUid: userId,
        },
        trial_period_days: 7,
      },
    });

    return {
      sessionId: session.id,
      url: session.url,
    };
  } catch (error: any) {
    functions.logger.error('Error creating Stripe subscription:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to create subscription: ${error.message}`
    );
  }
});

/**
 * Handles Stripe webhook events
 */
export const handleStripeWebhook = functions.https.onRequest(async (req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const sig = req.headers['stripe-signature'] as string;
    let event;

    try {
      event = stripe.webhooks.constructEvent(req.rawBody, sig, stripeWebhookSecret);
    } catch (err: any) {
      functions.logger.error('Webhook signature verification failed:', err.message);
      res.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    try {
      switch (event.type) {
        case 'checkout.session.completed': {
          const session = event.data.object;
          const firebaseUid = session.metadata.firebaseUid;
          const subscriptionId = session.subscription;

          if (firebaseUid) {
            // Retrieve subscription details
            const subscription = await stripe.subscriptions.retrieve(subscriptionId);
            const currentPeriodEnd = new Date(subscription.current_period_end * 1000);
            const currentPeriodStart = new Date(subscription.current_period_start * 1000);

            await db.collection('users').doc(firebaseUid).update({
              subscriptionTier: 'premium',
              subscriptionId: subscriptionId,
              subscriptionStart: admin.firestore.Timestamp.fromDate(currentPeriodStart),
              subscriptionEnd: admin.firestore.Timestamp.fromDate(currentPeriodEnd),
              subscriptionStatus: subscription.status,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Record payment
            await db.collection('payments').add({
              userId: firebaseUid,
              provider: 'stripe',
              sessionId: session.id,
              subscriptionId: subscriptionId,
              amount: session.amount_total,
              currency: session.currency,
              status: 'completed',
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            functions.logger.info(`Subscription activated for user ${firebaseUid}`);
          }
          break;
        }

        case 'invoice.payment_succeeded': {
          const invoice = event.data.object;
          const subscriptionId = invoice.subscription;

          if (subscriptionId) {
            const subscription = await stripe.subscriptions.retrieve(subscriptionId);
            const firebaseUid = subscription.metadata.firebaseUid;

            if (firebaseUid) {
              const currentPeriodEnd = new Date(subscription.current_period_end * 1000);

              await db.collection('users').doc(firebaseUid).update({
                subscriptionEnd: admin.firestore.Timestamp.fromDate(currentPeriodEnd),
                subscriptionStatus: subscription.status,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              });

              await db.collection('payments').add({
                userId: firebaseUid,
                provider: 'stripe',
                invoiceId: invoice.id,
                subscriptionId: subscriptionId,
                amount: invoice.amount_paid,
                currency: invoice.currency,
                status: 'completed',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
              });
            }
          }
          break;
        }

        case 'customer.subscription.deleted': {
          const subscription = event.data.object;
          const firebaseUid = subscription.metadata.firebaseUid;

          if (firebaseUid) {
            await db.collection('users').doc(firebaseUid).update({
              subscriptionTier: 'free',
              subscriptionStatus: 'canceled',
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            functions.logger.info(`Subscription canceled for user ${firebaseUid}`);
          }
          break;
        }

        case 'customer.subscription.updated': {
          const subscription = event.data.object;
          const firebaseUid = subscription.metadata.firebaseUid;

          if (firebaseUid) {
            const currentPeriodEnd = new Date(subscription.current_period_end * 1000);

            await db.collection('users').doc(firebaseUid).update({
              subscriptionEnd: admin.firestore.Timestamp.fromDate(currentPeriodEnd),
              subscriptionStatus: subscription.status,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
          break;
        }

        default:
          functions.logger.info(`Unhandled Stripe event type: ${event.type}`);
      }

      res.json({ received: true });
    } catch (error: any) {
      functions.logger.error('Error processing Stripe webhook:', error);
      res.status(500).send(`Server Error: ${error.message}`);
    }
  });
});

// ================================================================
// RAZORPAY SUBSCRIPTION
// ================================================================

/**
 * Creates a Razorpay order for subscription
 * Expects: { amount (in paise), currency ("INR"), receipt, notes: { userId } }
 */
export const createRazorpayOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to create a payment order'
    );
  }

  const { amount, currency = 'INR', notes } = data;
  const userId = context.auth.uid;

  if (!amount || amount <= 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invalid amount. Must be a positive integer in paise.'
    );
  }

  try {
    const options = {
      amount: amount,
      currency: currency,
      receipt: `receipt_${userId}_${Date.now()}`,
      notes: {
        ...notes,
        firebaseUid: userId,
      },
      payment_capture: 1,
    };

    const order = await razorpay.orders.create(options);

    // Store order reference in Firestore
    await db.collection('payments').doc(order.id).set({
      userId: userId,
      provider: 'razorpay',
      orderId: order.id,
      amount: amount,
      currency: currency,
      status: 'created',
      receipt: order.receipt,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId: razorpayKeyId,
    };
  } catch (error: any) {
    functions.logger.error('Error creating Razorpay order:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to create order: ${error.message}`
    );
  }
});

/**
 * Handles Razorpay webhook events
 */
export const handleRazorpayWebhook = functions.https.onRequest(async (req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const webhookSecret = functions.config().razorpay?.webhook_secret || process.env.RAZORPAY_WEBHOOK_SECRET || '';

    // Verify webhook signature
    const expectedSignature = crypto
      .createHmac('sha256', webhookSecret)
      .update(JSON.stringify(req.body))
      .digest('hex');

    const receivedSignature = req.headers['x-razorpay-signature'] as string;

    if (expectedSignature !== receivedSignature) {
      functions.logger.error('Razorpay webhook signature verification failed');
      res.status(400).send('Invalid signature');
      return;
    }

    try {
      const event = req.body.event;
      const payload = req.body.payload;

      switch (event) {
        case 'payment.captured': {
          const payment = payload.payment.entity;
          const orderId = payment.order_id;

          // Get the order to find the user
          const orderDoc = await db.collection('payments').doc(orderId).get();
          if (!orderDoc.exists) {
            functions.logger.error(`Order ${orderId} not found in Firestore`);
            res.json({ status: 'ok' });
            return;
          }

          const orderData = orderDoc.data()!;
          const userId = orderData.userId;

          // Update payment record
          await db.collection('payments').doc(orderId).update({
            paymentId: payment.id,
            status: 'captured',
            method: payment.method,
            bank: payment.bank,
            wallet: payment.wallet,
            fee: payment.fee,
            tax: payment.tax,
            capturedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // Activate subscription for the user (30 days from now)
          const now = new Date();
          const subscriptionEnd = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

          await db.collection('users').doc(userId).update({
            subscriptionTier: 'premium',
            subscriptionStart: admin.firestore.Timestamp.fromDate(now),
            subscriptionEnd: admin.firestore.Timestamp.fromDate(subscriptionEnd),
            subscriptionStatus: 'active',
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          functions.logger.info(`Razorpay payment captured for user ${userId}`);
          break;
        }

        case 'payment.failed': {
          const payment = payload.payment.entity;
          const orderId = payment.order_id;

          await db.collection('payments').doc(orderId).update({
            status: 'failed',
            errorDescription: payment.error_description,
            failedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          functions.logger.error(`Razorpay payment failed for order ${orderId}`);
          break;
        }

        case 'subscription.charged': {
          const subscription = payload.subscription.entity;
          const payment = payload.payment.entity;

          // Find user by notes
          const userId = subscription.notes?.firebaseUid;

          if (userId) {
            // Extend subscription by 30 days
            const userDoc = await db.collection('users').doc(userId).get();
            const userData = userDoc.data();
            const currentEnd = userData?.subscriptionEnd?.toDate() || new Date();
            const newEnd = new Date(currentEnd.getTime() + 30 * 24 * 60 * 60 * 1000);

            await db.collection('users').doc(userId).update({
              subscriptionEnd: admin.firestore.Timestamp.fromDate(newEnd),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }

          await db.collection('payments').add({
            userId: userId || 'unknown',
            provider: 'razorpay',
            subscriptionId: subscription.id,
            paymentId: payment.id,
            amount: payment.amount,
            currency: payment.currency,
            status: 'completed',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          break;
        }

        default:
          functions.logger.info(`Unhandled Razorpay event: ${event}`);
      }

      res.json({ status: 'ok' });
    } catch (error: any) {
      functions.logger.error('Error processing Razorpay webhook:', error);
      res.status(500).send(`Server Error: ${error.message}`);
    }
  });
});

// ================================================================
// CERTIFICATE GENERATION
// ================================================================

/**
 * Generates a certificate PDF when a topic is completed
 * Triggered by: onCreate of campaign completion or manually called
 */
export const generateCertificate = functions.firestore
  .document('campaigns/{campaignId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Only generate when status changes to 'completed'
    if (!beforeData || !afterData) {
      return null;
    }

    if (beforeData.status !== 'completed' && afterData.status === 'completed') {
      const { childId, topicId, days } = afterData;

      try {
        // Fetch child info
        const childDoc = await db.collection('children').doc(childId).get();
        if (!childDoc.exists) {
          functions.logger.error(`Child ${childId} not found`);
          return null;
        }
        const childData = childDoc.data()!;

        // Fetch topic info
        const topicDoc = await db.collection('topics').doc(topicId).get();
        if (!topicDoc.exists) {
          functions.logger.error(`Topic ${topicId} not found`);
          return null;
        }
        const topicData = topicDoc.data()!;

        // Calculate overall score from all 5 days
        let totalQuizScore = 0;
        let totalQuizMax = 0;
        for (let day = 1; day <= 5; day++) {
          const dayData = days?.[day];
          if (dayData?.quizScore !== undefined) {
            totalQuizScore += dayData.quizScore || 0;
            totalQuizMax += dayData.quizMax || 10;
          }
        }
        const accuracy = totalQuizMax > 0 ? Math.round((totalQuizScore / totalQuizMax) * 100) : 0;
        const score = accuracy >= 80 ? 'A+' : accuracy >= 60 ? 'B' : accuracy >= 40 ? 'C' : 'D';

        // Generate PDF
        const certId = `${childId}_${topicId}_${Date.now()}`;
        const pdfBuffer = await generateCertificatePdf({
          childName: childData.name,
          topicTitle: topicData.title,
          subject: topicData.subject,
          grade: childData.grade,
          score: score,
          accuracy: accuracy,
          date: new Date().toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
          }),
        });

        // Upload to Firebase Storage
        const bucket = storage.bucket();
        const filename = `certificates/${childId}/${topicId}/${certId}.pdf`;
        const file = bucket.file(filename);

        await file.save(pdfBuffer, {
          metadata: {
            contentType: 'application/pdf',
            metadata: {
              childId,
              topicId,
              generatedAt: new Date().toISOString(),
            },
          },
        });

        // Make publicly accessible
        await file.makePublic();

        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

        // Store certificate record in Firestore
        await db.collection('certificates').doc(certId).set({
          childId,
          topicId,
          childName: childData.name,
          topicTitle: topicData.title,
          subject: topicData.subject,
          grade: childData.grade,
          score,
          accuracy,
          totalQuizScore,
          totalQuizMax,
          pdfUrl: publicUrl,
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
          shared: false,
        });

        // Update campaign with certificate reference
        await change.after.ref.update({
          certificatesGenerated: admin.firestore.FieldValue.arrayUnion(certId),
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update child stats
        const childRef = db.collection('children').doc(childId);
        await childRef.update({
          'stats.totalTopics': admin.firestore.FieldValue.increment(1),
          'stats.totalQuizzes': admin.firestore.FieldValue.increment(5),
          'stats.accuracy': accuracy,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        functions.logger.info(`Certificate generated for child ${childId}, topic ${topicId}`);
        return { certId, publicUrl };
      } catch (error: any) {
        functions.logger.error('Error generating certificate:', error);
        return null;
      }
    }

    return null;
  });

/**
 * Generates a certificate PDF using PDFKit
 */
async function generateCertificatePdf(data: {
  childName: string;
  topicTitle: string;
  subject: string;
  grade: number;
  score: string;
  accuracy: number;
  date: string;
}): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      layout: 'landscape',
      size: 'A4',
      margins: { top: 40, bottom: 40, left: 40, right: 40 },
    });

    const buffers: Buffer[] = [];
    doc.on('data', (buffer: Buffer) => buffers.push(buffer));
    doc.on('end', () => resolve(Buffer.concat(buffers)));
    doc.on('error', reject);

    const pageWidth = doc.page.width;
    const pageHeight = doc.page.height;

    // Background border
    doc.rect(20, 20, pageWidth - 40, pageHeight - 40).lineWidth(4).stroke('#1CB0F6');
    doc.rect(30, 30, pageWidth - 60, pageHeight - 60).lineWidth(2).stroke('#58CC02');

    // Title
    doc.fontSize(42).font('Helvetica-Bold').fillColor('#1CB0F6')
      .text('🌟 CERTIFICATE OF ACHIEVEMENT 🌟', { align: 'center' });

    doc.moveDown(1.5);

    // Award text
    doc.fontSize(18).font('Helvetica').fillColor('#333333')
      .text('This certificate is proudly awarded to', { align: 'center' });

    doc.moveDown(0.5);

    // Child name
    doc.fontSize(36).font('Helvetica-Bold').fillColor('#FF6B6B')
      .text(data.childName, { align: 'center' });

    doc.moveDown(0.8);

    // Description
    doc.fontSize(16).font('Helvetica').fillColor('#333333')
      .text(`for successfully completing the topic`, { align: 'center' });

    doc.moveDown(0.3);

    // Topic title
    doc.fontSize(24).font('Helvetica-Bold').fillColor('#58CC02')
      .text(data.topicTitle, { align: 'center' });

    doc.moveDown(0.3);

    // Subject and Grade
    doc.fontSize(16).font('Helvetica').fillColor('#555555')
      .text(`Subject: ${data.subject}  |  Grade: ${data.grade}`, { align: 'center' });

    doc.moveDown(1);

    // Score details
    doc.fontSize(14).font('Helvetica').fillColor('#333333')
      .text(`Score: ${data.score}  |  Accuracy: ${data.accuracy}%`, { align: 'center' });

    doc.moveDown(2);

    // Date and signature
    doc.fontSize(12).font('Helvetica').fillColor('#888888')
      .text(`Date: ${data.date}`, { align: 'center' });

    doc.moveDown(0.5);

    doc.fontSize(12).font('Helvetica').fillColor('#888888')
      .text('ParentHero - Making Learning Fun! 🚀', { align: 'center' });

    // Footer decoration
    doc.moveTo(100, pageHeight - 80)
      .lineTo(pageWidth - 100, pageHeight - 80)
      .lineWidth(1).stroke('#1CB0F6');

    doc.end();
  });
}

// ================================================================
// CONTENT GENERATION
// ================================================================

/**
 * Triggers content generation for a topic when a campaign is created (topic pinned)
 */
export const generateContent = functions.firestore
  .document('campaigns/{campaignId}')
  .onCreate(async (snap, context) => {
    const campaign = snap.data();
    const { childId, topicId } = campaign;

    if (!childId || !topicId) {
      functions.logger.error('Missing childId or topicId in campaign');
      return null;
    }

    try {
      // Fetch topic to get subject and grade
      const topicDoc = await db.collection('topics').doc(topicId).get();
      if (!topicDoc.exists) {
        functions.logger.error(`Topic ${topicId} not found`);
        return null;
      }
      const topicData = topicDoc.data()!;

      // Fetch child info for personalization
      const childDoc = await db.collection('children').doc(childId).get();
      const childData = childDoc.exists ? childDoc.data()! : null;

      // Generate content for each of the 5 days
      const days = [1, 2, 3, 4, 5];
      const contentTypes = ['script', 'practice', 'quiz', 'beat_parent', 'spark'];

      for (const day of days) {
        for (const type of contentTypes) {
          const contentId = `${topicId}_${day}_${type}`;
          const existingDoc = await db.collection('content').doc(contentId).get();

          if (existingDoc.exists) {
            functions.logger.info(`Content ${contentId} already exists, skipping`);
            continue;
          }

          // Generate structured content based on type and day
          const content = generateDayContent(topicData, day, type, childData);

          await db.collection('content').doc(contentId).set({
            topicId,
            day,
            type,
            data: content,
            generatedAt: admin.firestore.FieldValue.serverTimestamp(),
            version: 1,
            grade: topicData.grade,
            subject: topicData.subject,
          });
        }
      }

      functions.logger.info(`Content generated for campaign ${context.params.campaignId}`);
      return { success: true };
    } catch (error: any) {
      functions.logger.error('Error generating content:', error);
      return null;
    }
  });

/**
 * Generates structured content for a specific day and type
 */
function generateDayContent(topicData: any, day: number, type: string, childData: any | null): any {
  const childName = childData?.name || 'Learner';
  const baseContent: any = {
    topicTitle: topicData.title,
    subject: topicData.subject,
    grade: topicData.grade,
    day,
    childName,
  };

  switch (type) {
    case 'script': {
      return {
        ...baseContent,
        sections: [
          {
            title: 'Introduction',
            content: `Welcome ${childName}! Today we're going to learn about ${topicData.title}. Let's start with something fun!`,
            duration: '2 min',
          },
          {
            title: 'Main Concept',
            content: `${topicData.title} is an important topic in ${topicData.subject}. Let me explain it step by step...`,
            duration: '5 min',
          },
          {
            title: 'Example',
            content: 'Here is a practical example to help you understand better...',
            duration: '3 min',
          },
          {
            title: 'Key Takeaways',
            content: 'Remember these important points from today\'s lesson...',
            duration: '2 min',
          },
        ],
        keyVocabulary: ['term1', 'term2', 'term3'],
        teachingTips: [
          'Use real-life examples to explain',
          'Encourage questions',
          'Practice with everyday objects',
        ],
      };
    }

    case 'practice': {
      return {
        ...baseContent,
        questions: generatePracticeQuestions(topicData, day),
        instructions: 'Read each question carefully and try to solve it on your own first.',
        difficultyLevel: day <= 2 ? 'easy' : day <= 4 ? 'medium' : 'hard',
      };
    }

    case 'quiz': {
      return {
        ...baseContent,
        questions: generateQuizQuestions(topicData, day),
        totalQuestions: 5,
        passingScore: 3,
        timeLimit: day * 2, // increasing time for later days
      };
    }

    case 'beat_parent': {
      return {
        ...baseContent,
        gameType: day % 2 === 0 ? 'speed_round' : 'challenge_round',
        questions: generateBeatParentQuestions(topicData, day),
        rules: [
          `${childName} goes first`,
          'Each correct answer earns 10 points',
          'The player with the most points wins',
          'Parent must answer in half the time!',
        ],
        parentAdvantage: 'Parent answers in half the time',
        childAdvantage: `${childName} goes first`,
      };
    }

    case 'spark': {
      const sparkFacts: Record<string, string[]> = {
        'Math': [
          'Did you know? The word "mathematics" comes from the Greek word "mathēma" meaning "knowledge"!',
          'Zero was invented in India by the mathematician Aryabhata!',
          'A pizza slice is actually a triangle! 🍕',
        ],
        'Science': [
          'Did you know? Your brain uses about 20% of your body\'s energy!',
          'Honey never spoils! Archaeologists found 3000-year-old honey in Egyptian tombs.',
          'A day on Venus is longer than a year on Venus!',
        ],
        'English': [
          'Did you know? "I am" is the shortest complete sentence in English!',
          'The word "alphabet" comes from the first two Greek letters: alpha and beta.',
          'There are over 170,000 words in the English language!',
        ],
      };

      const subjectFacts = sparkFacts[topicData.subject] || sparkFacts['Math'];
      const factIndex = (day - 1) % subjectFacts.length;

      return {
        ...baseContent,
        type: 'fun_fact',
        content: subjectFacts[factIndex],
        activity: {
          title: `Daily Spark - Day ${day}`,
          description: `Today's fun fact about ${topicData.subject}!`,
          emoji: ['🤔', '🌟', '✨', '🎯', '💡'][day - 1],
        },
      };
    }

    default:
      return baseContent;
  }
}

/**
 * Generates practice questions for a topic
 */
function generatePracticeQuestions(topicData: any, day: number): any[] {
  const questions = [];
  const numQuestions = day <= 2 ? 3 : day <= 4 ? 5 : 7;

  for (let i = 0; i < numQuestions; i++) {
    questions.push({
      id: `practice_${topicData.topicId}_${day}_${i}`,
      question: `${topicData.title} - Practice Question ${i + 1}: Solve the following...`,
      type: i % 3 === 0 ? 'multiple_choice' : i % 3 === 1 ? 'fill_blank' : 'open_ended',
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      correctAnswer: 'Option A',
      explanation: 'Here is why this is the correct answer...',
      difficulty: day <= 2 ? 'easy' : day <= 4 ? 'medium' : 'hard',
      points: 10,
    });
  }

  return questions;
}

/**
 * Generates quiz questions for a topic
 */
function generateQuizQuestions(topicData: any, day: number): any[] {
  const questions = [];
  for (let i = 0; i < 5; i++) {
    questions.push({
      id: `quiz_${topicData.topicId}_${day}_${i}`,
      question: `Question ${i + 1}: About ${topicData.title} - Day ${day}...`,
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      correctAnswer: Math.floor(Math.random() * 4),
      explanation: 'Explanation for this question...',
      difficulty: day <= 2 ? 'easy' : day <= 4 ? 'medium' : 'hard',
      points: 10,
      tag: topicData.subTopics?.[i % (topicData.subTopics?.length || 1)] || topicData.title,
    });
  }
  return questions;
}

/**
 * Generates "Beat the Parent" game questions
 */
function generateBeatParentQuestions(topicData: any, day: number): any[] {
  const questions = [];
  for (let i = 0; i < 5; i++) {
    questions.push({
      id: `beat_parent_${topicData.topicId}_${day}_${i}`,
      question: `Challenge Question ${i + 1}: Think fast! About ${topicData.title}...`,
      options: ['A', 'B', 'C', 'D'],
      correctAnswer: Math.floor(Math.random() * 4),
      funFact: 'Fun fact related to this question...',
      timeLimit: day <= 3 ? 30 : 20, // less time for later days
      points: 10 + (day * 2),
    });
  }
  return questions;
}

// ================================================================
// ANALYTICS TRACKING
// ================================================================

/**
 * Tracks custom analytics events from the client
 */
export const trackAnalytics = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to track analytics'
    );
  }

  const { event, properties = {} } = data;
  const userId = context.auth.uid;

  if (!event || typeof event !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Event name is required and must be a string'
    );
  }

  try {
    const eventDoc = {
      userId,
      event,
      properties: {
        ...properties,
        timestamp: new Date().toISOString(),
      },
      platform: properties.platform || 'unknown',
      appVersion: properties.appVersion || '1.0.0',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('analytics').add(eventDoc);

    // Update user's analytics summary
    await db.collection('users').doc(userId).collection('analyticsSummary').doc('events').set(
      {
        [event]: admin.firestore.FieldValue.increment(1),
        lastEvent: event,
        lastEventAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    functions.logger.info(`Analytics event tracked: ${event} for user ${userId}`);
    return { success: true };
  } catch (error: any) {
    functions.logger.error('Error tracking analytics:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to track analytics: ${error.message}`
    );
  }
});

// ================================================================
// DAILY SPARK PUSH NOTIFICATION
// ================================================================

/**
 * Sends daily spark push notifications
 * Triggered by scheduled function (runs daily)
 */
export const sendDailySparkPush = functions.pubsub
  .schedule('0 8 * * *') // Runs every day at 8:00 AM
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    try {
      functions.logger.info('Starting daily spark push notification job');

      // Get all users with active subscriptions who have notifications enabled
      const usersSnapshot = await db.collection('users')
        .where('subscriptionStatus', 'in', ['active', 'trialing'])
        .where('preferences.notifications', '==', true)
        .get();

      if (usersSnapshot.empty) {
        functions.logger.info('No users to send daily spark to');
        return null;
      }

      let sentCount = 0;

      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();

        // Get user's children with active campaigns
        const childrenSnapshot = await db.collection('children')
          .where('parentId', '==', userId)
          .get();

        if (childrenSnapshot.empty) {
          continue;
        }

        // Find children with active campaigns
        for (const childDoc of childrenSnapshot.docs) {
          const childId = childDoc.id;
          const childData = childDoc.data();

          const campaignsSnapshot = await db.collection('campaigns')
            .where('childId', '==', childId)
            .where('status', '==', 'active')
            .limit(1)
            .get();

          if (campaignsSnapshot.empty) {
            continue;
          }

          const campaign = campaignsSnapshot.docs[0].data();

          // Determine the current day in the campaign
          const startedAt = campaign.startedAt?.toDate() || new Date();
          const daysSinceStart = Math.floor(
            (Date.now() - startedAt.getTime()) / (1000 * 60 * 60 * 24)
          );
          const currentDay = Math.min(daysSinceStart + 1, 5);

          // Build notification message
          let notificationTitle: string;
          let notificationBody: string;

          const sparkMessages = [
            `🌟 Good morning ${childData.name}! Time for your daily learning adventure!`,
            `📚 Hey ${childData.name}, your ${campaign.topicId.replace(/_/g, ' ')} lesson is waiting!`,
            `🎯 Ready to learn something new today, ${childData.name}? Let's go!`,
            `✨ ${childData.name}, today's spark is here! Can you guess what it is?`,
            `🏆 Day ${currentDay} awaits, ${childData.name}! You're doing great!`,
          ];

          const randomIndex = Math.floor(Math.random() * sparkMessages.length);
          notificationTitle = '✨ Daily Spark from ParentHero!';
          notificationBody = sparkMessages[randomIndex];

          try {
            // Get user's FCM token
            const tokensSnapshot = await db.collection('users')
              .doc(userId)
              .collection('fcmTokens')
              .get();

            const tokens: string[] = [];
            tokensSnapshot.forEach((tokenDoc) => {
              tokens.push(tokenDoc.id);
            });

            if (tokens.length > 0) {
              const message: admin.messaging.MulticastMessage = {
                tokens,
                notification: {
                  title: notificationTitle,
                  body: notificationBody,
                },
                data: {
                  type: 'daily_spark',
                  childId,
                  campaignId: campaignsSnapshot.docs[0].id,
                  currentDay: currentDay.toString(),
                  topicId: campaign.topicId,
                  click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
                android: {
                  priority: 'high',
                  notification: {
                    channelId: 'daily_spark',
                    priority: 'high',
                    defaultSound: true,
                  },
                },
                apns: {
                  payload: {
                    aps: {
                      sound: 'default',
                      badge: 1,
                      alert: {
                        title: notificationTitle,
                        body: notificationBody,
                      },
                    },
                  },
                },
              };

              const response = await messaging.sendEachForMulticast(message);
              functions.logger.info(
                `Sent daily spark to ${childData.name}: ${response.successCount} success, ${response.failureCount} failures`
              );
              sentCount++;
            }

            // Record notification in Firestore
            await db.collection('notifications').add({
              userId,
              childId,
              type: 'daily_spark',
              title: notificationTitle,
              body: notificationBody,
              data: {
                childId,
                campaignId: campaignsSnapshot.docs[0].id,
                currentDay,
                topicId: campaign.topicId,
              },
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          } catch (notifError: any) {
            functions.logger.error(
              `Failed to send notification for child ${childId}:`,
              notifError
            );
          }
        }
      }

      functions.logger.info(`Daily spark push notifications sent to ${sentCount} children`);
      return { success: true, sentCount };
    } catch (error: any) {
      functions.logger.error('Error in sendDailySparkPush:', error);
      return null;
    }
  });
