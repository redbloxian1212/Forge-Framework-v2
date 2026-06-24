--[=[
    DataPaths.luau

    @desc:
    - Prevents hardcoding paths across the codebase
    - Changes in data structure only need to be updated here (Single Source of Truth)
    - Easy access to deeply nested data without hardcoding strings everywhere

    @usage:
    Assuming your data structure looks like this:
    {
        Cash = number,
        Inventory = {
            Swords = { name: string, damage: number }[],
            Armor = { name: string, defense: number }[],
        },
        Skills = {
            Swords = { level: number }
        }
    }

    DataPaths would look like this:

    {   
        Cash = {"Cash"},
        Inventory = {
            Swords = {"Inventory", "Swords"},
            Armor = {"Inventory", "Armor"},
        },
        Skills = {
            Swords = {"Skills", "Swords"}
        },
    }
]=]

return {}
