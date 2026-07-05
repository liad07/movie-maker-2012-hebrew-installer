using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Threading;
using System.Windows.Forms;

namespace SetupLauncher
{
    internal sealed class ScreenshotCaptureContext : ApplicationContext
    {
        private readonly SetupWizardForm _wizard;
        private readonly string _outputDirectory;
        private int _stepIndex;

        private readonly (string FileName, int Step, string Language)[] _steps =
        {
            ("01-welcome.png", 0, "Hebrew"),
            ("02-location.png", 1, "Hebrew"),
            ("03-language.png", 2, "Hebrew"),
            ("04-ready.png", 3, "Hebrew"),
            ("05-installing.png", 4, "Hebrew"),
            ("06-finish-hebrew.png", 5, "Hebrew"),
            ("07-finish-english.png", 5, "English")
        };

        public ScreenshotCaptureContext(string outputDirectory)
        {
            _outputDirectory = outputDirectory;
            Directory.CreateDirectory(outputDirectory);

            _wizard = new SetupWizardForm
            {
                StartPosition = FormStartPosition.CenterScreen
            };
            _wizard.PrepareInstallation(string.Empty);
            _wizard.Shown += WizardShown;
            _wizard.Show();
        }

        private void WizardShown(object sender, EventArgs e)
        {
            var timer = new System.Windows.Forms.Timer { Interval = 300 };
            timer.Tick += (o, args) =>
            {
                timer.Stop();
                timer.Dispose();
                CaptureNextStep();
            };
            timer.Start();
        }

        private void CaptureNextStep()
        {
            if (_stepIndex >= _steps.Length)
            {
                _wizard.Close();
                ExitThread();
                return;
            }

            var step = _steps[_stepIndex];
            _wizard.SelectedLanguage = step.Language;
            _wizard.ShowStepForCapture(step.Step);
            _wizard.Refresh();
            Application.DoEvents();
            Thread.Sleep(200);

            var outputPath = Path.Combine(_outputDirectory, step.FileName);
            using (var bitmap = new Bitmap(_wizard.Width, _wizard.Height))
            {
                _wizard.DrawToBitmap(bitmap, new Rectangle(0, 0, _wizard.Width, _wizard.Height));
                bitmap.Save(outputPath, ImageFormat.Png);
            }

            _stepIndex++;

            var timer = new System.Windows.Forms.Timer { Interval = 150 };
            timer.Tick += (o, args) =>
            {
                timer.Stop();
                timer.Dispose();
                CaptureNextStep();
            };
            timer.Start();
        }
    }

    internal static class WizardScreenshotCapture
    {
        public static int CaptureAll(string outputDirectory)
        {
            SetupLogger.Info("Screenshot capture started: " + outputDirectory);
            Application.Run(new ScreenshotCaptureContext(outputDirectory));
            SetupLogger.Info("Screenshot capture finished.");
            return 0;
        }
    }
}
