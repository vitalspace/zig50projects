const std = @import("std");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

fn isClicked(x: i32, y: i32, buttonRect: c.SDL_Rect, event: c.SDL_Event) !bool {
    return (event.type == c.SDL_MOUSEBUTTONDOWN and
        event.button.button == c.SDL_BUTTON_LEFT and
        x >= buttonRect.x and x <= buttonRect.x + buttonRect.w and
        y >= buttonRect.y and y <= buttonRect.y + buttonRect.h);
}

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        std.debug.print("Unable to initialize SDL: {s}", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("Button", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 800, 600, c.SDL_WINDOW_OPENGL) orelse {
        std.debug.print("Unable to create window: {s}", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const render = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        std.debug.print("Unable to create render: {s}", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(render);

    var count: i32 = 0;
    var quit = false;
    var buttonClicked = false;
    var buttonRect = c.SDL_Rect{ .x = (800 - 100) / 2, .y = (600 - 50) / 2, .w = 100, .h = 50 };

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_MOUSEBUTTONDOWN => {
                    if (try isClicked(event.button.x, event.button.y, buttonRect, event)) {
                        std.debug.print("Count: {d} \n", .{count});
                        count += 1;
                        buttonClicked = !buttonClicked;
                    }
                },
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(render, 255, 255, 255, 255);
        _ = c.SDL_RenderClear(render);

        if (buttonClicked) {
            _ = c.SDL_SetRenderDrawColor(render, 0, 255, 0, 255); // Green
        } else {
            _ = c.SDL_SetRenderDrawColor(render, 0, 0, 255, 255); // Blue
        }

        _ = c.SDL_RenderFillRect(render, &buttonRect);
        _ = c.SDL_RenderPresent(render);
    }
}
