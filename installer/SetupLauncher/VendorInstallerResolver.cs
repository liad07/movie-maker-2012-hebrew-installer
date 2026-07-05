using System.IO;

namespace SetupLauncher
{
    internal static class VendorInstallerResolver
    {
        private static readonly string[] CandidateNames =
        {
            "MovieMaker2012-Base.exe",
            "Movie Maker 2012.exe",
            "Move Maker 2012.exe"
        };

        public static string Resolve(string packageRoot)
        {
            foreach (var name in CandidateNames)
            {
                var path = Path.Combine(packageRoot, name);
                if (File.Exists(path))
                {
                    return path;
                }
            }

            return null;
        }
    }
}
