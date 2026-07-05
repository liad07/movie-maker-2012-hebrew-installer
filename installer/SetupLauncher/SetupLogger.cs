using System;
using System.IO;

namespace SetupLauncher
{
    internal static class SetupLogger
    {
        private static readonly object SyncRoot = new object();
        private static readonly string LogPath = Path.Combine(
            Path.GetTempPath(),
            "MovieMaker2012-Hebrew-Setup.log");

        public static string LogFilePath
        {
            get { return LogPath; }
        }

        public static void Info(string message)
        {
            Write("INFO", message);
        }

        public static void Error(string message)
        {
            Write("ERROR", message);
        }

        private static void Write(string level, string message)
        {
            var line = string.Format(
                "{0:yyyy-MM-dd HH:mm:ss} [{1}] {2}",
                DateTime.Now,
                level,
                message);

            lock (SyncRoot)
            {
                File.AppendAllText(LogPath, line + Environment.NewLine);
            }
        }
    }
}
