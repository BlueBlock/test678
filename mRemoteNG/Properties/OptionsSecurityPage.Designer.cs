﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace mRemoteNG.Properties {
    
    
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.VisualStudio.Editors.SettingsDesigner.SettingsSingleFileGenerator", "17.1.0.0")]
    internal sealed partial class OptionsSecurityPage : global::System.Configuration.ApplicationSettingsBase {
        
        private static OptionsSecurityPage defaultInstance = ((OptionsSecurityPage)(global::System.Configuration.ApplicationSettingsBase.Synchronized(new OptionsSecurityPage())));
        
        public static OptionsSecurityPage Default {
            get {
                return defaultInstance;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("False")]
        public bool EncryptCompleteConnectionsFile {
            get {
                return ((bool)(this["EncryptCompleteConnectionsFile"]));
            }
            set {
                this["EncryptCompleteConnectionsFile"] = value;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("AES")]
        public global::mRemoteNG.Security.BlockCipherEngines EncryptionEngine {
            get {
                return ((global::mRemoteNG.Security.BlockCipherEngines)(this["EncryptionEngine"]));
            }
            set {
                this["EncryptionEngine"] = value;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("GCM")]
        public global::mRemoteNG.Security.BlockCipherModes EncryptionBlockCipherMode {
            get {
                return ((global::mRemoteNG.Security.BlockCipherModes)(this["EncryptionBlockCipherMode"]));
            }
            set {
                this["EncryptionBlockCipherMode"] = value;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("10000")]
        public int EncryptionKeyDerivationIterations {
            get {
                return ((int)(this["EncryptionKeyDerivationIterations"]));
            }
            set {
                this["EncryptionKeyDerivationIterations"] = value;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("True")]
        public bool cbSecurityPageInOptionMenu {
            get {
                return ((bool)(this["cbSecurityPageInOptionMenu"]));
            }
            set {
                this["cbSecurityPageInOptionMenu"] = value;
            }
        }
    }
}
