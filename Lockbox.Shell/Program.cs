// See https://aka.ms/new-console-template for more information
using Lockbox.Test;


var test = new PdfExtractor();
Task<bool> task = test.Execute();
task.Wait();