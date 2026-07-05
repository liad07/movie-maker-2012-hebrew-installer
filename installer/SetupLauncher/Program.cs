using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

namespace SetupLauncher
{
    internal static class Program
    {
        [STAThread]
        private static int Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (TryHandleDeveloperCommand(args, out var developerExitCode))
            {
                return developerExitCode;
            }

            if (!IsAdministrator())
            {
                return TryRelaunchAsAdministrator(args) ? 0 : 1;
            }

            using (var payload = new PayloadExtractor())
            {
                try
                {
                    SetupLogger.Info(InstallerVersion.DisplayName + " v" + InstallerVersion.Version);
                    payload.Extract();

                    using (var wizard = new SetupWizardForm())
                    {
                        wizard.PrepareInstallation(payload.PackageRoot);
                        var result = wizard.ShowDialog();
                        if (result == DialogResult.Cancel)
                        {
                            return wizard.InstallationSucceeded ? 0 : 1;
                        }

                        return wizard.InstallationSucceeded ? 0 : 1;
                    }
                }
                catch (Exception exception)
                {
                    SetupLogger.Error(exception.Message);
                    MessageBox.Show(
                        exception.Message,
                        WizardStrings.WindowTitle,
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                    return 1;
                }
            }
        }

        private static bool TryHandleDeveloperCommand(string[] args, out int exitCode)
        {
            exitCode = 0;

            if (args.Length >= 2 && string.Equals(args[0], "--capture-screenshots", StringComparison.OrdinalIgnoreCase))
            {
                exitCode = WizardScreenshotCapture.CaptureAll(args[1]);
                return true;
            }

            if (args.Length >= 1 && string.Equals(args[0], "--create-gif", StringComparison.OrdinalIgnoreCase))
            {
                if (args.Length < 3)
                {
                    Console.Error.WriteLine("Usage: --create-gif <screenshotsDir> <outputGif>");
                    exitCode = 1;
                    return true;
                }

                var frames = Directory.GetFiles(args[1], "0*.png");
                Array.Sort(frames, StringComparer.OrdinalIgnoreCase);
                GifCreator.CreateFromPngFrames(args[2], frames, 1800);
                Console.WriteLine("Created GIF: " + args[2]);
                return true;
            }

            if (args.Length >= 1 && string.Equals(args[0], "--print-hash", StringComparison.OrdinalIgnoreCase))
            {
                var executablePath = Process.GetCurrentProcess().MainModule?.FileName;
                if (string.IsNullOrEmpty(executablePath))
                {
                    Console.Error.WriteLine("Unable to resolve executable path.");
                    exitCode = 1;
                    return true;
                }

                Console.WriteLine(PayloadIntegrity.ComputeFileSha256(executablePath));
                return true;
            }

            return false;
        }

        private static bool IsAdministrator()
        {
            using (var identity = System.Security.Principal.WindowsIdentity.GetCurrent())
            {
                var principal = new System.Security.Principal.WindowsPrincipal(identity);
                return principal.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);
            }
        }

        private static bool TryRelaunchAsAdministrator(string[] args)
        {
            try
            {
                var executablePath = Process.GetCurrentProcess().MainModule?.FileName;
                if (string.IsNullOrEmpty(executablePath))
                {
                    return false;
                }

                var argumentList = string.Join(" ", QuoteArguments(args));
                Process.Start(new ProcessStartInfo
                {
                    FileName = executablePath,
                    Arguments = argumentList,
                    UseShellExecute = true,
                    Verb = "runas"
                });
                return true;
            }
            catch (Win32Exception exception) when (exception.NativeErrorCode == 1223)
            {
                return false;
            }
        }

        private static string[] QuoteArguments(string[] args)
        {
            if (args == null || args.Length == 0)
            {
                return Array.Empty<string>();
            }

            var quoted = new string[args.Length];
            for (var index = 0; index < args.Length; index++)
            {
                quoted[index] = "\"" + args[index].Replace("\"", "\\\"") + "\"";
            }

            return quoted;
        }
    }
}
