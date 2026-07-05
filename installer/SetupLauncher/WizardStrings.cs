namespace SetupLauncher
{
    internal static class WizardStrings
    {
        public const string WindowTitle = "התקנה - Windows Movie Maker";
        public const string Browse = "עיון...";
        public const string Back = "< הקודם";
        public const string Next = "הבא >";
        public const string Cancel = "ביטול";
        public const string Finish = "סיום";
        public const string Install = "התקן";
        public const string Credit = "מתקין קהילתי: LIAD KADOSH (LK07)\r\ngithub.com/liad07";

        public const string WelcomeTitle = "ברוכים הבאים לאשף התקנת Windows Movie Maker";
        public const string WelcomeBody =
            "אשף זה יתקין את Windows Movie Maker 2012 במחשב שלך.\r\n\r\n" +
            "סגרו את Movie Maker ו-Photo Gallery אם הם פתוחים.\r\n\r\n" +
            "לחץ על \"הבא\" כדי להמשיך, או \"ביטול\" כדי לצאת.";

        public const string LocationTitle = "מיקום התקנה";
        public const string LocationSubtitle = "Movie Maker מותקן במיקום הסטנדרטי של Windows Live";
        public const string LocationBody =
            "התוכנית תותקן במיקום הסטנדרטי של Windows Live:\r\n\r\n" +
            "Program Files (x86)\\Windows Live\\Photo Gallery\r\n\r\n" +
            "לא ניתן לשנות את מיקום קבצי התוכנית. מסך זה מציג מידע בלבד.";
        public const string LocationFooter =
            "גודל הורדה: ~183 MB · גודל מותקן: ~85 MB · מומלץ 500 MB פנויים במהלך ההתקנה";

        public const string LanguageTitle = "בחירת שפת התוכנית";
        public const string LanguageSubtitle = "בחרו את שפת Movie Maker.";
        public const string LanguageBody =
            "בחרו האם Movie Maker יופעל בעברית או באנגלית.\r\n\r\n" +
            "בחירה באנגלית לא תמחק קבצי עברית קיימים — רק לא תחיל את חבילת העברית.";
        public const string HebrewOption = "עברית";
        public const string EnglishOption = "English (אנגלית)";

        public const string ReadyTitle = "מוכן להתקנה";
        public const string ReadySubtitle = "ההתקנה מוכנה להתחיל.";
        public const string ReadyBody = "הרכיבים הבאים יותקנו. לחץ \"התקן\" כדי להמשיך.";

        public const string InstallingTitle = "מתקין";
        public const string InstallingSubtitle = "אנא המתן בזמן שההתקנה מתבצעת.";
        public const string InstallingBody = "ההתקנה עשויה להימשך מספר דקות. אל תסגרו את החלון.";
        public const string InstallingStatus = "מכין התקנה...";

        public const string CompleteTitle = "סיום אשף ההתקנה של Windows Movie Maker";
        public const string CompleteHebrew =
            "Windows Movie Maker הותקן בעברית.\r\n\r\nלחץ \"סיום\" כדי לצאת.";
        public const string CompleteEnglish =
            "Movie Maker הוגדר לאנגלית.\r\n\r\nלחץ \"סיום\" כדי לצאת.";

        public const string AlreadyInstalledPrompt =
            "Movie Maker כבר מותקן.\r\n\r\nלהמשיך ולהחיל שוב את הגדרות השפה שנבחרו?";
        public const string RunningProcessWarning =
            "סגרו את Movie Maker או Photo Gallery לפני שממשיכים.";
        public const string ErrorLogSuffix = "קובץ יומן:\r\n";

        public static readonly string[] ReadyComponents =
        {
            "Windows Movie Maker 2012 (מתקין בסיס מאומת)",
            "Windows Live Photo Gallery (תלויות)",
            "DirectX runtime components",
            "חבילת שפה (עברית או אנגלית)"
        };
    }
}
