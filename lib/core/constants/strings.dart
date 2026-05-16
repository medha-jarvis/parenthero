/// All application string constants for ParentHero.
///
/// Centralized strings for easy localization and maintenance.
class AppStrings {
  AppStrings._();

  // ==================================================================
  // App Identity
  // ==================================================================

  static const String appName = 'ParentHero';
  static const String appTagline = 'Making Learning Fun!';
  static const String appDescription =
      'AI-powered learning companion for kids Grades 1-5';

  // ==================================================================
  // Authentication
  // ==================================================================

  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String signInWithGoogle = 'Continue with Google';
  static const String signInWithApple = 'Continue with Apple';
  static const String signInWithEmail = 'Continue with Email';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String sendResetLink = 'Send Reset Link';
  static const String resetLinkSent = 'Password reset link sent! Check your email.';
  static const String checkEmail = 'Check your email';
  static const String verifyEmail = 'Verify Email';
  static const String emailVerified = 'Email Verified!';
  static const String verificationEmailSent = 'Verification email sent.';

  // ==================================================================
  // Form Labels
  // ==================================================================

  static const String name = 'Name';
  static const String fullName = 'Full Name';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String phone = 'Phone Number';
  static const String age = 'Age';
  static const String grade = 'Grade';
  static const String board = 'Board';
  static const String subject = 'Subject';
  static const String topic = 'Topic';
  static const String search = 'Search';
  static const String searchTopics = 'Search topics...';

  // ==================================================================
  // Validation Messages
  // ==================================================================

  static const String nameRequired = 'Name is required';
  static const String emailRequired = 'Email is required';
  static const String validEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String ageRequired = 'Age is required';
  static const String gradeRequired = 'Grade is required';
  static const String fieldRequired = 'This field is required';

  // ==================================================================
  // Onboarding
  // ==================================================================

  static const String welcome = 'Welcome to ParentHero!';
  static const String letsGetStarted = "Let's get started!";
  static const String addChild = 'Add Child';
  static const String addChildProfile = 'Add Child Profile';
  static const String editChildProfile = 'Edit Child Profile';
  static const String childName = "Child's Name";
  static const String childAge = "Child's Age";
  static const String childGrade = "Child's Grade";
  static const String chooseAvatar = 'Choose an Avatar';
  static const String selectBoard = 'Select Board';
  static const String cbse = 'CBSE';
  static const String icse = 'ICSE';
  static const String stateBoard = 'State Board';
  static const String otherBoard = 'Other';
  static const String howOld = 'How old is your child?';
  static const String whatGrade = 'What grade are they in?';

  // ==================================================================
  // Dashboard
  // ==================================================================

  static const String dashboard = 'Dashboard';
  static const String myChildren = 'My Children';
  static const String learningJourney = 'Learning Journey';
  static const String progress = 'Progress';
  static const String streak = 'Streak';
  static const String days = 'days';
  static const String topicsCompleted = 'Topics Completed';
  static const String quizzesTaken = 'Quizzes Taken';
  static const String accuracy = 'Accuracy';
  static const String noChildrenYet = 'No children added yet';
  static const String addFirstChild = 'Add your first child to get started!';
  static const String activeCampaign = 'Active Campaign';
  static const String noActiveCampaign = 'No active campaign';
  static const String pinATopic = 'Pin a Topic';
  static const String continueLearning = 'Continue Learning';

  // ==================================================================
  // Campaign / Learning
  // ==================================================================

  static const String pinTopic = 'Pin Topic';
  static const String unpinTopic = 'Unpin Topic';
  static const String day = 'Day';
  static const String daysRemaining = 'days remaining';
  static const String teachingScript = 'Teaching Script';
  static const String practice = 'Practice';
  static const String quiz = 'Quiz';
  static const String beatTheParent = 'Beat the Parent';
  static const String dailySpark = 'Daily Spark';
  static const String startLearning = 'Start Learning';
  static const String continueLearningToday = 'Continue Learning';
  static const String markComplete = 'Mark Complete';
  static const String completed = 'Completed';
  static const String locked = 'Locked';
  static const String comingSoon = 'Coming Soon';
  static const String topicLibrary = 'Topic Library';
  static const String browseTopics = 'Browse Topics';
  static const String filterByGrade = 'Filter by Grade';
  static const String filterBySubject = 'Filter by Subject';
  static const String allSubjects = 'All Subjects';
  static const String math = 'Math';
  static const String science = 'Science';
  static const String english = 'English';
  static const String evs = 'EVS';

  // ==================================================================
  // Quiz
  // ==================================================================

  static const String quizTime = 'Quiz Time!';
  static const String question = 'Question';
  static const String of = 'of';
  static const String score = 'Score';
  static const String correct = 'Correct!';
  static const String incorrect = 'Incorrect';
  static const String nextQuestion = 'Next Question';
  static const String seeResults = 'See Results';
  static const String tryAgain = 'Try Again';
  static const String greatJob = 'Great Job!';
  static const String keepPracticing = 'Keep Practicing!';
  static const String quizComplete = 'Quiz Complete!';
  static const String yourScore = 'Your Score';

  // ==================================================================
  // Certificate
  // ==================================================================

  static const String certificate = 'Certificate';
  static const String certificateOfAchievement = 'Certificate of Achievement';
  static const String congratulations = 'Congratulations!';
  static const String topicCompleted = 'Topic Completed!';
  static const String downloadCertificate = 'Download Certificate';
  static const String shareCertificate = 'Share Certificate';
  static const String viewCertificate = 'View Certificate';
  static const String awardedTo = 'Awarded to';
  static const String forCompleting = 'for successfully completing';

  // ==================================================================
  // Subscription / Payments
  // ==================================================================

  static const String subscription = 'Subscription';
  static const String choosePlan = 'Choose Your Plan';
  static const String currentPlan = 'Current Plan';
  static const String upgrade = 'Upgrade';
  static const String downgrade = 'Downgrade';
  static const String cancelSubscription = 'Cancel Subscription';
  static const String subscribe = 'Subscribe';
  static const String freeTrial = '7-Day Free Trial';
  static const String monthly = 'Monthly';
  static const String annual = 'Annual';
  static const String family = 'Family';
  static const String bestValue = 'Best Value';
  static const String mostPopular = 'Most Popular';
  static const String perMonth = '/month';
  static const String perYear = '/year';
  static const String savePercent = 'Save 17%';
  static const String payment = 'Payment';
  static const String paymentMethod = 'Payment Method';
  static const String cardNumber = 'Card Number';
  static const String expiryDate = 'Expiry Date';
  static const String cvv = 'CVV';
  static const String payNow = 'Pay Now';
  static const String processing = 'Processing...';
  static const String paymentSuccessful = 'Payment Successful!';
  static const String paymentFailed = 'Payment Failed';
  static const String tryAgainPayment = 'Please try again';
  static const String razorpay = 'Razorpay';
  static const String stripe = 'Stripe';
  static const String upi = 'UPI';
  static const String creditCard = 'Credit Card';
  static const String debitCard = 'Debit Card';
  static const String netBanking = 'Net Banking';
  static const String wallet = 'Wallet';

  // ==================================================================
  // Settings
  // ==================================================================

  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String notifications = 'Notifications';
  static const String pushNotifications = 'Push Notifications';
  static const String emailNotifications = 'Email Notifications';
  static const String dailyReminder = 'Daily Reminder';
  static const String theme = 'Theme';
  static const String lightMode = 'Light Mode';
  static const String darkMode = 'Dark Mode';
  static const String systemDefault = 'System Default';
  static const String language = 'Language';
  static const String englishLanguage = 'English';
  static const String hindiLanguage = 'Hindi';
  static const String about = 'About';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String helpAndSupport = 'Help & Support';
  static const String contactUs = 'Contact Us';
  static const String version = 'Version';
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountWarning =
      'This action cannot be undone. All your data will be permanently deleted.';

  // ==================================================================
  // Errors
  // ==================================================================

  static const String error = 'Error';
  static const String somethingWentWrong = 'Something went wrong';
  static const String networkError = 'Network error. Please check your connection.';
  static const String tryAgainLater = 'Please try again later.';
  static const String userNotFound = 'User not found';
  static const String invalidEmail = 'Invalid email address';
  static const String wrongPassword = 'Wrong password';
  static const String emailAlreadyInUse = 'Email already in use';
  static const String weakPassword = 'Password is too weak';
  static const String tooManyRequests = 'Too many requests. Please try again later.';
  static const String operationNotAllowed = 'This operation is not allowed';
  static const String sessionExpired = 'Session expired. Please sign in again.';
  static const String permissionDenied = 'You do not have permission to perform this action';
  static const String documentNotFound = 'Document not found';

  // ==================================================================
  // General UI
  // ==================================================================

  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String update = 'Update';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String skip = 'Skip';
  static const String done = 'Done';
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String retry = 'Retry';
  static const String refresh = 'Refresh';
  static const String share = 'Share';
  static const String copy = 'Copy';
  static const String copied = 'Copied!';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';

  // ==================================================================
  // Empty States
  // ==================================================================

  static const String noTopicsFound = 'No topics found';
  static const String noTopicsForFilter = 'No topics match your filters';
  static const String noCampaignsYet = 'No learning campaigns yet';
  static const String noCertificatesYet = 'No certificates earned yet';
  static const String noNotifications = 'No notifications';
  static const String emptySearchResults = 'No results found for your search';
}