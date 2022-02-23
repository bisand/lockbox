using PuppeteerSharp;

namespace Lockbox.Test;

public class PdfExtractor
{
    public async Task<bool> Execute()
    {
        Console.WriteLine("Hello, World!");
        var options = new LaunchOptions
        {
            Headless = true,
            Args = new string[] { "--cap-add=SYS_ADMIN", "--no-sandbox" }
        };

        // Console.WriteLine("Downloading chromium");
        // using var browserFetcher = new BrowserFetcher();
        // await browserFetcher.DownloadAsync();

        Console.WriteLine("Navigating google");
        using (var browser = await Puppeteer.LaunchAsync(options))
        using (var page = await browser.NewPageAsync())
        {
            await page.GoToAsync("http://www.google.com");

            Console.WriteLine("Generating PDF");
            await page.PdfAsync(Path.Combine(Directory.GetCurrentDirectory(), "google.pdf"));

            Console.WriteLine("Export completed");
        }

        return true;
    }
}
