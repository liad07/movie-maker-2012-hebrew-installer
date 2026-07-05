using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace SetupLauncher
{
    internal static partial class PayloadIntegrity
    {
        public static void VerifyEmbeddedPayload(Stream payloadStream)
        {
            if (string.Equals(ExpectedPayloadSha256, "PLACEHOLDER", StringComparison.OrdinalIgnoreCase))
            {
                payloadStream.Position = 0;
                return;
            }

            var actual = ComputeSha256(payloadStream);
            payloadStream.Position = 0;

            if (!string.Equals(actual, ExpectedPayloadSha256, StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("Embedded installer payload failed integrity verification.");
            }
        }

        public static string ComputeFileSha256(string filePath)
        {
            using (var stream = File.OpenRead(filePath))
            {
                return ComputeSha256(stream);
            }
        }

        public static string ComputeSha256(Stream stream)
        {
            using (var algorithm = SHA256.Create())
            {
                var hash = algorithm.ComputeHash(stream);
                var builder = new StringBuilder(hash.Length * 2);
                foreach (var value in hash)
                {
                    builder.Append(value.ToString("X2"));
                }

                return builder.ToString();
            }
        }
    }
}
