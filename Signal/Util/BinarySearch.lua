--!strict
--!native
--!optimize 2
--@danel_rucci

--[=[
    @class BinarySearch

    Generic binary search utilities for sorted arrays.

    The module is intentionally allocation free and accepts a comparator function, allowing it to work
    with any data type.

    Comparators must define a strict weak ordering.
]=]

export type Comparator<T> = (left : T, right : T) -> boolean

local BinarySearch = {}

--[=[
    @function LowerBound
    @within BinarySearch
    @param array {T} -- The sorted array to search.
    @param value T -- The value to search for.
    @param compare Comparator<T> -- The comparator function to use for ordering.
    @return number -- The index of the first element that is not less than <value>.
    @yields

    Returns the insertion index that preserves ordering.
    Equivalent to C++ std::lower_bound.
]=]
function BinarySearch.LowerBound<T>(array : {T}, value: T, compare : Comparator<T>) : number
    local low : number = 1
    local high : number = #array

    while low <= high do
        local mid : number = (low + high) // 2

        if compare(array[mid], value) then
            low = mid + 1
        else
            high = mid - 1
        end
    end

    return low
end

--[=[
    @function UpperBound
    @within BinarySearch
    @param array {T} -- The sorted array to search.
    @param value T -- The value to search for.
    @param compare Comparator<T> -- The comparator function to use for ordering.
    @return number -- The index of the first element that is greater than <value>.
    @yields

    Returns the insertion index after the last equivalent element.
    Equivalent to C++ std::upper_bound.
]=]
function BinarySearch.UpperBound<T>(array : {T}, value : T, compare : Comparator<T>) : number
    local low : number = 1
    local high : number = #array

    while low <= high do
        local mid : number = (low + high) // 2

        if compare(value, array[mid]) then
            high = mid - 1
        else
            low = mid + 1
        end
    end

    return low
end

return table.freeze(BinarySearch)