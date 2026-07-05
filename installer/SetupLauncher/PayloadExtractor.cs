using System;
using System.IO;
using System.IO.Compression;
using System.Reflection;

namespace SetupLauncher
{
    internal sealed class PayloadExtractor : IDisposable
    {
        public string PackageRoot { get; private set; } = string.Empty;

        public void Extract()
        {
            var extractRoot = Path.Combine(Path.GetTempPath(), "MovieMaker2012Hebrew", Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(extractRoot);

            using (var resourceStream = Assembly.GetExecutingAssembly().GetManifestResourceStream("SetupLauncher.payload.zip"))
            {
                if (resourceStream == null)
                {
                    throw new InvalidOperationException("Embedded installer payload was not found.");
                }

                using (var verifiedStream = new MemoryStream())
                {
                    resourceStream.CopyTo(verifiedStream);
                    verifiedStream.Position = 0;
                    PayloadIntegrity.VerifyEmbeddedPayload(verifiedStream);

                    var zipPath = Path.Combine(extractRoot, "payload.zip");
                    using (var fileStream = File.Create(zipPath))
                    {
                        verifiedStream.Position = 0;
                        verifiedStream.CopyTo(fileStream);
                    }

                    ZipFile.ExtractToDirectory(zipPath, extractRoot);
                    File.Delete(zipPath);
                }
            }

            PackageRoot = extractRoot;
        }

        public void Dispose()
        {
            if (string.IsNullOrEmpty(PackageRoot) || !Directory.Exists(PackageRoot))
            {
                return;
            }

            try
            {
                Directory.Delete(PackageRoot, true);
                SetupLogger.Info("Removed temporary payload folder.");
            }
            catch
            {
                SetupLogger.Info("Temporary payload folder left in place: " + PackageRoot);
            }
        }
    }
}
