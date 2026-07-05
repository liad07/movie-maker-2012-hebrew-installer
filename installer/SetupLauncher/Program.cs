using System;
using System.Diagnostics;
using System.Security.Principal;
using System.Windows.Forms;

namespace SetupLauncher
{
    internal static class Program
    {
        [STAThread]
        private static int Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (!IsAdministrator())
            {
                RelaunchAsAdministrator();
                return 0;
            }

            try
            {
                SetupLogger.Info("Community installer launched.");
                var packageRoot = SetupWizardForm.ExtractPayload();

                using (var wizard = new SetupWizardForm())
                {
                    wizard.PrepareInstallation(packageRoot);
                    var result = wizard.ShowDialog();
                    if (result == DialogResult.Cancel)
                    {
                        return 0;
                    }

                    return wizard.InstallationSucceeded ? 0 : 1;
                }
            }
            catch (Exception exception)
            {
                MessageBox.Show(
                    exception.Message,
                    "Setup - Windows Movie Maker",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return 1;
            }
        }

        private static bool IsAdministrator()
        {
            using (var identity = WindowsIdentity.GetCurrent())
            {
                var principal = new WindowsPrincipal(identity);
                return principal.IsInRole(WindowsBuiltInRole.Administrator);
            }
        }

        private static void RelaunchAsAdministrator()
        {
            var executablePath = Process.GetCurrentProcess().MainModule.FileName;
            Process.Start(new ProcessStartInfo
            {
                FileName = executablePath,
                UseShellExecute = true,
                Verb = "runas"
            });
        }
    }
}
