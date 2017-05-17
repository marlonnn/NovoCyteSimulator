namespace NovoCyteSimulator
{
    partial class NovoCyteSimulatorForm
    {
        /// <summary>
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            Exit();
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要修改
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(NovoCyteSimulatorForm));
            this.bar1 = new DevComponents.DotNetBar.Bar();
            this.txtInstrumentState = new DevComponents.DotNetBar.LabelItem();
            this.ribbonControl1 = new DevComponents.DotNetBar.RibbonControl();
            this.btnItemOpen = new DevComponents.DotNetBar.ButtonItem();
            this.styleManager1 = new DevComponents.DotNetBar.StyleManager(this.components);
            this.labelX1 = new DevComponents.DotNetBar.LabelX();
            this.cbBoxMachineStatus = new DevComponents.DotNetBar.Controls.ComboBoxEx();
            ((System.ComponentModel.ISupportInitialize)(this.bar1)).BeginInit();
            this.SuspendLayout();
            // 
            // bar1
            // 
            this.bar1.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.bar1.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.bar1.Items.AddRange(new DevComponents.DotNetBar.BaseItem[] {
            this.txtInstrumentState});
            this.bar1.Location = new System.Drawing.Point(5, 175);
            this.bar1.MaximumSize = new System.Drawing.Size(0, 25);
            this.bar1.Name = "bar1";
            this.bar1.PaddingBottom = 0;
            this.bar1.PaddingTop = -1;
            this.bar1.Size = new System.Drawing.Size(441, 17);
            this.bar1.Stretch = true;
            this.bar1.Style = DevComponents.DotNetBar.eDotNetBarStyle.StyleManagerControlled;
            this.bar1.TabIndex = 6;
            this.bar1.TabStop = false;
            this.bar1.Text = "bar1";
            // 
            // txtInstrumentState
            // 
            this.txtInstrumentState.BeginGroup = true;
            this.txtInstrumentState.ForeColor = System.Drawing.Color.Green;
            this.txtInstrumentState.Name = "txtInstrumentState";
            this.txtInstrumentState.PaddingLeft = 2;
            this.txtInstrumentState.PaddingRight = 5;
            this.txtInstrumentState.Text = "Instrument not connected";
            // 
            // ribbonControl1
            // 
            // 
            // 
            // 
            this.ribbonControl1.BackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square;
            this.ribbonControl1.CaptionVisible = true;
            this.ribbonControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ribbonControl1.KeyTipsFont = new System.Drawing.Font("Tahoma", 7F);
            this.ribbonControl1.Location = new System.Drawing.Point(5, 1);
            this.ribbonControl1.Name = "ribbonControl1";
            this.ribbonControl1.Padding = new System.Windows.Forms.Padding(0, 0, 0, 3);
            this.ribbonControl1.QuickToolbarItems.AddRange(new DevComponents.DotNetBar.BaseItem[] {
            this.btnItemOpen});
            this.ribbonControl1.Size = new System.Drawing.Size(441, 174);
            this.ribbonControl1.Style = DevComponents.DotNetBar.eDotNetBarStyle.StyleManagerControlled;
            this.ribbonControl1.SystemText.MaximizeRibbonText = "&Maximize the Ribbon";
            this.ribbonControl1.SystemText.MinimizeRibbonText = "Mi&nimize the Ribbon";
            this.ribbonControl1.SystemText.QatAddItemText = "&Add to Quick Access Toolbar";
            this.ribbonControl1.SystemText.QatCustomizeMenuLabel = "<b>Customize Quick Access Toolbar</b>";
            this.ribbonControl1.SystemText.QatCustomizeText = "&Customize Quick Access Toolbar...";
            this.ribbonControl1.SystemText.QatDialogAddButton = "&Add >>";
            this.ribbonControl1.SystemText.QatDialogCancelButton = "Cancel";
            this.ribbonControl1.SystemText.QatDialogCaption = "Customize Quick Access Toolbar";
            this.ribbonControl1.SystemText.QatDialogCategoriesLabel = "&Choose commands from:";
            this.ribbonControl1.SystemText.QatDialogOkButton = "OK";
            this.ribbonControl1.SystemText.QatDialogPlacementCheckbox = "&Place Quick Access Toolbar below the Ribbon";
            this.ribbonControl1.SystemText.QatDialogRemoveButton = "&Remove";
            this.ribbonControl1.SystemText.QatPlaceAboveRibbonText = "&Place Quick Access Toolbar above the Ribbon";
            this.ribbonControl1.SystemText.QatPlaceBelowRibbonText = "&Place Quick Access Toolbar below the Ribbon";
            this.ribbonControl1.SystemText.QatRemoveItemText = "&Remove from Quick Access Toolbar";
            this.ribbonControl1.TabGroupHeight = 14;
            this.ribbonControl1.TabIndex = 7;
            this.ribbonControl1.Text = "ribbonControl1";
            // 
            // btnItemOpen
            // 
            this.btnItemOpen.Image = ((System.Drawing.Image)(resources.GetObject("btnItemOpen.Image")));
            this.btnItemOpen.Name = "btnItemOpen";
            this.btnItemOpen.Text = "Open";
            this.btnItemOpen.Click += new System.EventHandler(this.btnItemOpen_Click);
            // 
            // styleManager1
            // 
            this.styleManager1.ManagerStyle = DevComponents.DotNetBar.eStyle.Office2010Blue;
            this.styleManager1.MetroColorParameters = new DevComponents.DotNetBar.Metro.ColorTables.MetroColorGeneratorParameters(System.Drawing.Color.White, System.Drawing.Color.FromArgb(((int)(((byte)(43)))), ((int)(((byte)(87)))), ((int)(((byte)(154))))));
            // 
            // labelX1
            // 
            // 
            // 
            // 
            this.labelX1.BackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square;
            this.labelX1.Location = new System.Drawing.Point(42, 45);
            this.labelX1.Name = "labelX1";
            this.labelX1.Size = new System.Drawing.Size(90, 23);
            this.labelX1.TabIndex = 1;
            this.labelX1.Text = "Machine Status";
            // 
            // cbBoxMachineStatus
            // 
            this.cbBoxMachineStatus.DisplayMember = "Text";
            this.cbBoxMachineStatus.DrawMode = System.Windows.Forms.DrawMode.OwnerDrawFixed;
            this.cbBoxMachineStatus.FormattingEnabled = true;
            this.cbBoxMachineStatus.ItemHeight = 14;
            this.cbBoxMachineStatus.Location = new System.Drawing.Point(128, 45);
            this.cbBoxMachineStatus.Name = "cbBoxMachineStatus";
            this.cbBoxMachineStatus.Size = new System.Drawing.Size(121, 20);
            this.cbBoxMachineStatus.Style = DevComponents.DotNetBar.eDotNetBarStyle.StyleManagerControlled;
            this.cbBoxMachineStatus.TabIndex = 1;
            this.cbBoxMachineStatus.SelectedIndexChanged += new System.EventHandler(this.MachineStatus_SelectedIndexChanged);
            // 
            // NovoCyteSimulatorForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(451, 194);
            this.Controls.Add(this.cbBoxMachineStatus);
            this.Controls.Add(this.labelX1);
            this.Controls.Add(this.ribbonControl1);
            this.Controls.Add(this.bar1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "NovoCyteSimulatorForm";
            this.Text = "NovoCyte Simulator Form";
            ((System.ComponentModel.ISupportInitialize)(this.bar1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private DevComponents.DotNetBar.Bar bar1;
        private DevComponents.DotNetBar.LabelItem txtInstrumentState;
        private DevComponents.DotNetBar.RibbonControl ribbonControl1;
        private DevComponents.DotNetBar.ButtonItem btnItemOpen;
        private DevComponents.DotNetBar.StyleManager styleManager1;
        private DevComponents.DotNetBar.LabelX labelX1;
        private DevComponents.DotNetBar.Controls.ComboBoxEx cbBoxMachineStatus;
    }
}

