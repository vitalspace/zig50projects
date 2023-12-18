const std = @import("std");

const Object = struct {
    id: i32,
    name: []const u8,
};

fn binarySearchByName(array: []const Object, searchedValue: []const u8) ?Object {
    var start: usize = 0;
    var end: usize = array.len - 1;

    while (start <= end) {
        const mid = (start + end) / 2;
        const comparison = compareByName(array[mid], searchedValue);

        if (comparison == 0) {
            return array[mid];
        } else if (comparison < 0) {
            start = mid + 1;
        } else {
            end = mid - 1;
        }
    }

    return null;
}

fn compareByName(object: Object, searchedValue: []const u8) i32 {
    if (std.mem.eql(u8, object.name, searchedValue)) {
        return 0;
    } else if (std.mem.lessThan(u8, object.name, searchedValue)) {
        return -1;
    } else {
        return 1;
    }
}

pub fn main() !void {
    var array: [3]Object = .{ .{ .id = 1, .name = "Object1" }, .{ .id = 2, .name = "Object3" }, .{ .id = 3, .name = "Object2" } };
    std.sort.insertion(Object, array[0..], {}, compareObjectsByName);

    const searchedName = "Object2";
    const foundObject = binarySearchByName(&array, searchedName) orelse return;

    std.debug.print("Object with name '{s}' found: id: {}, name: {s}\n", .{ searchedName, foundObject.id, foundObject.name });
}

fn compareObjectsByName(context: void, a: Object, b: Object) bool {
    _ = context;
    return std.mem.lessThan(u8, a.name, b.name);
}
