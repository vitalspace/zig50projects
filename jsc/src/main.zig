const std = @import("std"); // Imports the standard Zig module.
const jsc = @import("./jsc/jsc.zig"); // Imports the JavaScriptCore module.

pub fn main() !void { // Defines the main function that will run when the program starts.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; // Creates a general purpose allocator.
    const allocator = gpa.allocator(); // Gets the memory allocator.

    const context = jsc.JSGlobalContextCreate(null); // Creates a new JavaScript global context.
    const jsCode = jsc.JSStringCreateWithUTF8CString("const hello = 'hello world'; hello;"); // Creates a JavaScript string with the code to execute.
    const result = jsc.JSEvaluateScript(context, jsCode, null, null, 0, null); // Evaluates the JavaScript code in the global context.

    const jsString = jsc.JSValueToStringCopy(context, result, null); // Converts the result of the evaluation to a JavaScript string.

    var buffer = try allocator.alloc(u8, jsc.JSStringGetMaximumUTF8CStringSize(jsString)); // Allocates memory for the output string.
    defer allocator.free(buffer); // Frees the allocated memory when the program ends.

    const str_len = jsc.JSStringGetUTF8CString(jsString, buffer.ptr, buffer.len); // Gets the length of the JavaScript string.
    const string = buffer[0..str_len]; // Creates a Zig string from the buffer.

    std.debug.print("{s}\n", .{string}); // Prints the string to the console.

    jsc.JSStringRelease(jsString); // Releases the JavaScript string.
    jsc.JSGlobalContextRelease(context); // Releases the JavaScript global context.
}
