using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

namespace SetupLauncher
{
    internal static class GifCreator
    {
        public static void CreateFromPngFrames(string outputPath, IReadOnlyList<string> framePaths, int delayMilliseconds)
        {
            if (framePaths.Count == 0)
            {
                throw new InvalidOperationException("No PNG frames were supplied.");
            }

            var centiseconds = Math.Max(1, delayMilliseconds / 10);
            var encoder = GetEncoder(ImageFormat.Gif);
            var saveParams = new EncoderParameters(1);

            using (var firstFrame = PrepareFrame(framePaths[0], centiseconds))
            {
                saveParams.Param[0] = new EncoderParameter(Encoder.SaveFlag, (long)EncoderValue.MultiFrame);
                firstFrame.Save(outputPath, encoder, saveParams);

                for (var index = 1; index < framePaths.Count; index++)
                {
                    using (var frame = PrepareFrame(framePaths[index], centiseconds))
                    {
                        saveParams.Param[0] = new EncoderParameter(Encoder.SaveFlag, (long)EncoderValue.FrameDimensionTime);
                        firstFrame.SaveAdd(frame, saveParams);
                    }
                }

                saveParams.Param[0] = new EncoderParameter(Encoder.SaveFlag, (long)EncoderValue.Flush);
                firstFrame.SaveAdd(saveParams);
            }
        }

        private static Bitmap PrepareFrame(string framePath, int centiseconds)
        {
            using (var source = new Bitmap(framePath))
            {
                var frame = new Bitmap(source.Width, source.Height);
                using (var graphics = Graphics.FromImage(frame))
                {
                    graphics.Clear(Color.White);
                    graphics.DrawImage(source, 0, 0, source.Width, source.Height);
                }

                GifPropertyHelper.SetFrameDelay(frame, centiseconds);
                return frame;
            }
        }

        private static ImageCodecInfo GetEncoder(ImageFormat format)
        {
            foreach (var codec in ImageCodecInfo.GetImageEncoders())
            {
                if (codec.FormatID == format.Guid)
                {
                    return codec;
                }
            }

            throw new InvalidOperationException("GIF encoder was not found.");
        }
    }

    internal static class GifPropertyHelper
    {
        public static void SetFrameDelay(Image image, int centiseconds)
        {
            var item = CreatePropertyItem();
            item.Id = 20736;
            item.Type = 4;
            item.Len = 4;
            item.Value = BitConverter.GetBytes(centiseconds);
            image.SetPropertyItem(item);
        }

        private static PropertyItem CreatePropertyItem()
        {
            var constructor = typeof(PropertyItem).GetConstructor(
                System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic,
                null,
                Type.EmptyTypes,
                null);

            if (constructor == null)
            {
                throw new InvalidOperationException("Unable to create GIF property metadata.");
            }

            return (PropertyItem)constructor.Invoke(Array.Empty<object>());
        }
    }
}
