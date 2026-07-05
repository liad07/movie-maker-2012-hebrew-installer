using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace SetupLauncher
{
    internal sealed class SetupWizardForm : Form
    {
        private readonly Panel _headerPanel;
        private readonly Panel _headerIconPanel;
        private readonly Label _headerTitleLabel;
        private readonly Label _headerSubtitleLabel;
        private readonly Panel _contentPanel;
        private readonly Panel _contentIconPanel;
        private readonly Label _bodyLabel;
        private readonly TextBox _directoryTextBox;
        private readonly Button _browseButton;
        private readonly RadioButton _hebrewRadio;
        private readonly RadioButton _englishRadio;
        private readonly ListBox _readyList;
        private readonly ProgressBar _progressBar;
        private readonly Label _statusLabel;
        private readonly Label _footerInfoLabel;
        private readonly Label _creditLabel;
        private readonly Panel _bottomPanel;
        private readonly Button _backButton;
        private readonly Button _nextButton;
        private readonly Button _cancelButton;
        private readonly Button _finishButton;

        private int _stepIndex;
        private string _packageRoot = string.Empty;

        private const int StepWelcome = 0;
        private const int StepLocationInfo = 1;
        private const int StepLanguage = 2;
        private const int StepReady = 3;
        private const int StepInstalling = 4;
        private const int StepFinish = 5;

        public string SelectedLanguage { get; set; } = "Hebrew";
        public bool InstallationSucceeded { get; private set; }

        public SetupWizardForm()
        {
            Text = WizardStrings.WindowTitle;
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            StartPosition = FormStartPosition.CenterScreen;
            MaximizeBox = false;
            MinimizeBox = false;
            ClientSize = new Size(503, 312);
            Font = new Font("Segoe UI", 9F);
            BackColor = SystemColors.Control;

            _headerPanel = new Panel
            {
                Location = new Point(0, 0),
                Size = new Size(503, 58),
                BackColor = Color.White
            };
            _headerPanel.Paint += HeaderPanelPaint;

            _headerTitleLabel = new Label
            {
                AutoSize = false,
                Location = new Point(15, 8),
                Size = new Size(420, 18),
                Font = new Font("Segoe UI", 9F, FontStyle.Bold),
                BackColor = Color.White
            };

            _headerSubtitleLabel = new Label
            {
                AutoSize = false,
                Location = new Point(15, 26),
                Size = new Size(420, 16),
                BackColor = Color.White
            };

            _headerIconPanel = new Panel
            {
                Location = new Point(448, 8),
                Size = new Size(48, 48),
                BackColor = Color.White
            };
            _headerIconPanel.Paint += HeaderIconPaint;

            _headerPanel.Controls.Add(_headerTitleLabel);
            _headerPanel.Controls.Add(_headerSubtitleLabel);
            _headerPanel.Controls.Add(_headerIconPanel);

            _contentPanel = new Panel
            {
                Location = new Point(0, 58),
                Size = new Size(503, 199),
                BackColor = Color.White
            };

            _contentIconPanel = new Panel
            {
                Location = new Point(20, 16),
                Size = new Size(32, 32),
                BackColor = Color.White,
                Visible = false
            };
            _contentIconPanel.Paint += ContentIconPaint;

            _bodyLabel = new Label
            {
                AutoSize = false,
                Location = new Point(55, 16),
                Size = new Size(430, 70),
                BackColor = Color.White
            };

            _directoryTextBox = new TextBox
            {
                Location = new Point(55, 95),
                Size = new Size(350, 21),
                Visible = false,
                Text = @"C:\Program Files (x86)\Windows Live",
                RightToLeft = RightToLeft.No
            };

            _browseButton = new Button
            {
                Text = WizardStrings.Browse,
                Location = new Point(410, 93),
                Size = new Size(75, 23),
                Visible = false
            };
            _browseButton.Click += BrowseButtonClick;

            _hebrewRadio = new RadioButton
            {
                Text = WizardStrings.HebrewOption,
                Location = new Point(55, 95),
                Size = new Size(350, 22),
                Visible = false,
                Checked = true,
                BackColor = Color.White
            };

            _englishRadio = new RadioButton
            {
                Text = WizardStrings.EnglishOption,
                Location = new Point(55, 123),
                Size = new Size(350, 22),
                Visible = false,
                BackColor = Color.White
            };

            _readyList = new ListBox
            {
                Location = new Point(55, 90),
                Size = new Size(430, 95),
                Visible = false,
                BorderStyle = BorderStyle.Fixed3D,
                Enabled = false
            };
            _readyList.Items.AddRange(WizardStrings.ReadyComponents);

            _progressBar = new ProgressBar
            {
                Location = new Point(55, 100),
                Size = new Size(430, 18),
                Style = ProgressBarStyle.Marquee,
                Visible = false,
                MarqueeAnimationSpeed = 30
            };

            _statusLabel = new Label
            {
                Location = new Point(55, 125),
                Size = new Size(430, 40),
                Visible = false,
                BackColor = Color.White
            };

            _footerInfoLabel = new Label
            {
                Location = new Point(20, 175),
                Size = new Size(460, 16),
                Visible = false,
                BackColor = Color.White
            };

            _contentPanel.Controls.Add(_contentIconPanel);
            _contentPanel.Controls.Add(_bodyLabel);
            _contentPanel.Controls.Add(_directoryTextBox);
            _contentPanel.Controls.Add(_browseButton);
            _contentPanel.Controls.Add(_hebrewRadio);
            _contentPanel.Controls.Add(_englishRadio);
            _contentPanel.Controls.Add(_readyList);
            _contentPanel.Controls.Add(_progressBar);
            _contentPanel.Controls.Add(_statusLabel);
            _contentPanel.Controls.Add(_footerInfoLabel);

            _bottomPanel = new Panel
            {
                Location = new Point(0, 257),
                Size = new Size(503, 55),
                BackColor = SystemColors.Control
            };
            _bottomPanel.Paint += BottomPanelPaint;

            _creditLabel = new Label
            {
                AutoSize = false,
                Location = new Point(12, 18),
                Size = new Size(220, 28),
                ForeColor = Color.Gray,
                Text = WizardStrings.Credit
            };

            _backButton = new Button
            {
                Text = WizardStrings.Back,
                Location = new Point(248, 14),
                Size = new Size(75, 23),
                Enabled = false
            };
            _backButton.Click += BackButtonClick;

            _nextButton = new Button
            {
                Text = WizardStrings.Next,
                Location = new Point(329, 14),
                Size = new Size(75, 23)
            };
            _nextButton.Click += NextButtonClick;

            _cancelButton = new Button
            {
                Text = WizardStrings.Cancel,
                Location = new Point(410, 14),
                Size = new Size(75, 23)
            };
            _cancelButton.Click += CancelButtonClick;

            _finishButton = new Button
            {
                Text = WizardStrings.Finish,
                Location = new Point(410, 14),
                Size = new Size(75, 23),
                Visible = false
            };
            _finishButton.Click += FinishButtonClick;

            _bottomPanel.Controls.Add(_creditLabel);
            _bottomPanel.Controls.Add(_backButton);
            _bottomPanel.Controls.Add(_nextButton);
            _bottomPanel.Controls.Add(_cancelButton);
            _bottomPanel.Controls.Add(_finishButton);

            Controls.Add(_headerPanel);
            Controls.Add(_contentPanel);
            Controls.Add(_bottomPanel);

            AcceptButton = _nextButton;
            CancelButton = _cancelButton;

            ShowStep(StepWelcome);
        }

        public void PrepareInstallation(string packageRoot)
        {
            _packageRoot = packageRoot;
        }

        private static void HeaderPanelPaint(object sender, PaintEventArgs e)
        {
            var panel = (Panel)sender;
            using (var pen = new Pen(SystemColors.ControlDark))
            {
                e.Graphics.DrawLine(pen, 0, panel.Height - 1, panel.Width, panel.Height - 1);
            }
        }

        private static void BottomPanelPaint(object sender, PaintEventArgs e)
        {
            var panel = (Panel)sender;
            using (var pen = new Pen(SystemColors.ControlDark))
            {
                e.Graphics.DrawLine(pen, 0, 0, panel.Width, 0);
            }
        }

        private static void HeaderIconPaint(object sender, PaintEventArgs e)
        {
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            e.Graphics.FillRectangle(Brushes.White, 0, 0, 48, 48);
            e.Graphics.DrawRectangle(Pens.Gray, 4, 10, 30, 22);
            e.Graphics.FillRectangle(Brushes.LightGray, 6, 12, 26, 16);
            e.Graphics.DrawRectangle(Pens.Gray, 28, 24, 14, 14);
            e.Graphics.FillEllipse(Brushes.Silver, 30, 26, 10, 10);
        }

        private static void ContentIconPaint(object sender, PaintEventArgs e)
        {
            e.Graphics.FillRectangle(Brushes.Gold, 4, 6, 24, 20);
            e.Graphics.DrawRectangle(Pens.DarkGoldenrod, 4, 6, 24, 20);
            e.Graphics.DrawLine(Pens.DarkGoldenrod, 4, 12, 28, 12);
        }

        private void HideStepControls()
        {
            _contentIconPanel.Visible = false;
            _directoryTextBox.Visible = false;
            _browseButton.Visible = false;
            _hebrewRadio.Visible = false;
            _englishRadio.Visible = false;
            _readyList.Visible = false;
            _progressBar.Visible = false;
            _statusLabel.Visible = false;
            _footerInfoLabel.Visible = false;
            _finishButton.Visible = false;
            _nextButton.Visible = true;
            _bodyLabel.Location = new Point(55, 16);
            _bodyLabel.Size = new Size(430, 70);
        }

        private void ShowStep(int stepIndex)
        {
            _stepIndex = stepIndex;
            HideStepControls();
            _backButton.Enabled = stepIndex > StepWelcome && stepIndex < StepInstalling;
            _cancelButton.Enabled = stepIndex != StepInstalling;
            _nextButton.Enabled = stepIndex != StepInstalling;

            if (stepIndex == StepWelcome)
            {
                _headerTitleLabel.Text = WizardStrings.WelcomeTitle;
                _headerSubtitleLabel.Text = string.Empty;
                _bodyLabel.Location = new Point(20, 16);
                _bodyLabel.Size = new Size(460, 120);
                _bodyLabel.Text = WizardStrings.WelcomeBody;
                _nextButton.Text = WizardStrings.Next;
                return;
            }

            if (stepIndex == StepLocationInfo)
            {
                _headerTitleLabel.Text = WizardStrings.LocationTitle;
                _headerSubtitleLabel.Text = WizardStrings.LocationSubtitle;
                _contentIconPanel.Visible = true;
                _bodyLabel.Text = WizardStrings.LocationBody;
                _footerInfoLabel.Visible = true;
                _footerInfoLabel.Text = WizardStrings.LocationFooter;
                _nextButton.Text = WizardStrings.Next;
                return;
            }

            if (stepIndex == StepLanguage)
            {
                _headerTitleLabel.Text = WizardStrings.LanguageTitle;
                _headerSubtitleLabel.Text = WizardStrings.LanguageSubtitle;
                _contentIconPanel.Visible = true;
                _bodyLabel.Text = WizardStrings.LanguageBody;
                _hebrewRadio.Visible = true;
                _englishRadio.Visible = true;
                _nextButton.Text = WizardStrings.Next;
                return;
            }

            if (stepIndex == StepReady)
            {
                _headerTitleLabel.Text = WizardStrings.ReadyTitle;
                _headerSubtitleLabel.Text = WizardStrings.ReadySubtitle;
                _contentIconPanel.Visible = true;
                _bodyLabel.Text = WizardStrings.ReadyBody;
                _bodyLabel.Size = new Size(430, 35);
                _readyList.Visible = true;
                _nextButton.Text = WizardStrings.Install;
                return;
            }

            if (stepIndex == StepInstalling)
            {
                _headerTitleLabel.Text = WizardStrings.InstallingTitle;
                _headerSubtitleLabel.Text = WizardStrings.InstallingSubtitle;
                _bodyLabel.Location = new Point(20, 16);
                _bodyLabel.Size = new Size(460, 40);
                _bodyLabel.Text = WizardStrings.InstallingBody;
                _progressBar.Visible = true;
                _statusLabel.Visible = true;
                _statusLabel.Text = WizardStrings.InstallingStatus;
                _backButton.Enabled = false;
                _cancelButton.Enabled = false;
                _nextButton.Enabled = false;
                return;
            }

            _headerTitleLabel.Text = WizardStrings.CompleteTitle;
            _headerSubtitleLabel.Text = string.Empty;
            _bodyLabel.Location = new Point(20, 16);
            _bodyLabel.Size = new Size(460, 120);
            _bodyLabel.Text = SelectedLanguage == "Hebrew"
                ? WizardStrings.CompleteHebrew
                : WizardStrings.CompleteEnglish;
            _backButton.Enabled = false;
            _cancelButton.Enabled = false;
            _nextButton.Visible = false;
            _finishButton.Visible = true;
            AcceptButton = _finishButton;
        }

        public void ShowStepForCapture(int stepIndex)
        {
            ShowStep(stepIndex);
        }

        private void BrowseButtonClick(object sender, EventArgs e)
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.SelectedPath = _directoryTextBox.Text;
                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    _directoryTextBox.Text = dialog.SelectedPath;
                }
            }
        }

        private void BackButtonClick(object sender, EventArgs e)
        {
            if (_stepIndex > StepWelcome)
            {
                ShowStep(_stepIndex - 1);
            }
        }

        private void NextButtonClick(object sender, EventArgs e)
        {
            if (_stepIndex == StepWelcome)
            {
                if (IsMovieMakerProcessRunning())
                {
                    MessageBox.Show(WizardStrings.RunningProcessWarning, Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (IsMovieMakerInstalled())
                {
                    var result = MessageBox.Show(
                        WizardStrings.AlreadyInstalledPrompt,
                        Text,
                        MessageBoxButtons.YesNo,
                        MessageBoxIcon.Question);

                    if (result != DialogResult.Yes)
                    {
                        return;
                    }
                }

                ShowStep(_stepIndex + 1);
                return;
            }

            if (_stepIndex == StepLanguage)
            {
                SelectedLanguage = _hebrewRadio.Checked ? "Hebrew" : "English";
            }

            if (_stepIndex == StepReady)
            {
                ShowStep(StepInstalling);
                StartInstallation();
                return;
            }

            if (_stepIndex < StepReady)
            {
                ShowStep(_stepIndex + 1);
            }
        }

        private static bool IsMovieMakerProcessRunning()
        {
            var processNames = new[] { "MovieMaker", "WLXPhotoGallery", "PhotoGallery" };
            foreach (var processName in processNames)
            {
                if (Process.GetProcessesByName(processName).Length > 0)
                {
                    return true;
                }
            }

            return false;
        }

        private static bool IsMovieMakerInstalled()
        {
            var candidates = new[]
            {
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Windows Live", "Photo Gallery", "MovieMaker.exe"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Windows Live", "Photo Gallery", "MovieMaker.exe")
            };

            foreach (var candidate in candidates)
            {
                if (File.Exists(candidate))
                {
                    return true;
                }
            }

            return false;
        }

        private void CancelButtonClick(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Cancel;
            Close();
        }

        private void FinishButtonClick(object sender, EventArgs e)
        {
            DialogResult = DialogResult.OK;
            Close();
        }

        private void StartInstallation()
        {
            var worker = new BackgroundWorker { WorkerReportsProgress = true };
            worker.DoWork += InstallationWorkerDoWork;
            worker.ProgressChanged += InstallationWorkerProgressChanged;
            worker.RunWorkerCompleted += InstallationWorkerCompleted;
            worker.RunWorkerAsync();
        }

        private void InstallationWorkerProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            if (e.UserState is string status && !string.IsNullOrWhiteSpace(status))
            {
                _statusLabel.Text = status;
            }
        }

        private void InstallationWorkerDoWork(object sender, DoWorkEventArgs e)
        {
            var worker = (BackgroundWorker)sender;
            SetupLogger.Info("Installation started.");
            SetupLogger.Info("Selected language: " + SelectedLanguage);
            RunInstallationScript(_packageRoot, SelectedLanguage, worker);
            SetupLogger.Info("Installation completed successfully.");
        }

        private void InstallationWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            if (e.Error != null)
            {
                SetupLogger.Error(e.Error.Message);
                MessageBox.Show(
                    e.Error.Message + "\r\n\r\n" + WizardStrings.ErrorLogSuffix + SetupLogger.LogFilePath,
                    Text,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                DialogResult = DialogResult.Cancel;
                Close();
                return;
            }

            InstallationSucceeded = true;
            ShowStep(StepFinish);
        }

        private static void RunInstallationScript(string packageRoot, string language, BackgroundWorker worker)
        {
            var scriptPath = Path.Combine(packageRoot, "Install-HebrewMovieMaker.ps1");
            if (!File.Exists(scriptPath))
            {
                throw new InvalidOperationException("Install-HebrewMovieMaker.ps1 was not found in the payload.");
            }

            var arguments = "-NoProfile -ExecutionPolicy Bypass -File \"" + scriptPath +
                "\" -PackageRoot \"" + packageRoot + "\" -Language " + language + " -NoPrompt";

            SetupLogger.Info("Running installation script via PowerShell.");

            var progressPath = Path.Combine(Path.GetTempPath(), "MovieMaker2012-Hebrew-Setup.progress");
            if (File.Exists(progressPath))
            {
                File.Delete(progressPath);
            }

            var process = Process.Start(new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = arguments,
                UseShellExecute = false,
                CreateNoWindow = true
            });

            if (process == null)
            {
                throw new InvalidOperationException("Failed to start installation script.");
            }

            while (!process.WaitForExit(500))
            {
                if (!File.Exists(progressPath))
                {
                    continue;
                }

                var status = File.ReadAllText(progressPath).Trim();
                if (!string.IsNullOrWhiteSpace(status))
                {
                    worker.ReportProgress(0, status);
                }
            }

            if (process.ExitCode != 0)
            {
                throw new InvalidOperationException("Installation failed with exit code " + process.ExitCode + ".");
            }
        }
    }
}
