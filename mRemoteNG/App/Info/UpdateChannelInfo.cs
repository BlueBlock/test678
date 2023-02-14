using System;
using System.IO;
using System.Text;
using mRemoteNG.Properties;

// ReSharper disable InconsistentNaming

namespace mRemoteNG.App.Info
{
    public static class UpdateChannelInfo
    {
        public const string STABLE = "Stable";
        public const string PREVIEW = "Preview";
        public const string NIGHTLY = "Nightly";

        public const string STABLE_PORTABLE = "update-portable.txt";
        public const string PREVIEW_PORTABLE = "preview-update-portable.txt";
        public const string NIGHTLY_PORTABLE = "nightly-update-portable.txt";

        public const string STABLE_MSI = "update.txt";
        public const string PREVIEW_MSI = "preview-update.txt";
        public const string NIGHTLY_MSI = "nightly-update.txt";


        public static Uri GetUpdateChannelInfo()
        {
            var channel = IsValidChannel(Properties.OptionsUpdatesPage.Default.UpdateChannel) ? Properties.OptionsUpdatesPage.Default.UpdateChannel : STABLE;
            File.AppendAllText("C:\\github-source\\debug.log", "channel: " + channel);
            var e1 = GetUpdateTxtUri(channel);
            File.AppendAllText("C:\\github-source\\debug.log", "GetUpdateTxtUri: " + e1);
            return e1;
        }

        private static string GetChannelFileName(string channel)
        {
            var w1 = Runtime.IsPortableEdition
                ? GetChannelFileNamePortableEdition(channel)
                : GetChannelFileNameNormalEdition(channel);

            File.AppendAllText("C:\\github-source\\debug.log", "GetChannelFileName: " + w1);

            return w1;
        }

        private static string GetChannelFileNameNormalEdition(string channel)
        {
            File.AppendAllText("C:\\github-source\\debug.log", "GetChannelFileNameNormalEdition: " + channel);
            
            switch (channel)
            {
                case STABLE:
                    return STABLE_MSI;
                case PREVIEW:
                    return PREVIEW_MSI;
                case NIGHTLY:
                    return NIGHTLY_MSI;
                default:
                    return STABLE_MSI;
            }
        }

        private static string GetChannelFileNamePortableEdition(string channel)
        {
            File.AppendAllText("C:\\github-source\\debug.log", "GetChannelFileNamePortableEdition: " + channel);
            
            switch (channel)
            {
                case STABLE:
                    return STABLE_PORTABLE;
                case PREVIEW:
                    return PREVIEW_PORTABLE;
                case NIGHTLY:
                    return NIGHTLY_PORTABLE;
                default:
                    return STABLE_PORTABLE;
            }
        }

        private static Uri GetUpdateTxtUri(string channel)
        {
            var t1 = new Uri(new Uri(Properties.OptionsUpdatesPage.Default.UpdateAddress),
                           new Uri(GetChannelFileName(channel), UriKind.Relative));

            t1 = new Uri(new Uri(Properties.OptionsUpdatesPage.Default.UpdateAddress.Replace("https://mremoteng.org", "https://raw.githubusercontent.com/BlueBlock/test678/main/mRemoteNGTests/Resources")), new Uri(GetChannelFileName(channel), UriKind.Relative));

            File.AppendAllText("C:\\github-source\\debug.log", "GetUpdateTxtUri: " + t1);
            return t1;
        }

        private static bool IsValidChannel(string s)
        {
            return s.Equals(STABLE) || s.Equals(PREVIEW) || s.Equals(NIGHTLY);
        }
    }
}