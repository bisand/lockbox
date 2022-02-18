using PuppeteerSharp;

namespace Lockbox.Test;

public class PdfExtractor
{
    public bool async Execute()
    {
        Console.WriteLine("Hello, World!");
        var options = new LaunchOptions
        {
            Headless = true
        };

        Console.WriteLine("Downloading chromium");
        using var browserFetcher = new BrowserFetcher();
        await browserFetcher.DownloadAsync();

        Console.WriteLine("Navigating google");
        using (var browser = await Puppeteer.LaunchAsync(options))
        using (var page = await browser.NewPageAsync())
        {
            await page.GoToAsync("http://www.google.com");

            Console.WriteLine("Generating PDF");
            await page.PdfAsync(Path.Combine(Directory.GetCurrentDirectory(), "google.pdf"));

            Console.WriteLine("Export completed");

            if (!args.Any(arg => arg == "auto-exit"))
            {
                Console.ReadLine();
            }
        }

        return true;
    }
}
