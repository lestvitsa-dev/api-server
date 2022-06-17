module utils;

public string randomAlphanumericString(int length)
{
    import std.array : array;
    import std.ascii : letters, digits;
    import std.random : choice, Random, unpredictableSeed;
    import std.range : generate, take;
    import std.conv : to;

    auto rnd = Random(unpredictableSeed);
    auto symbols = array(letters ~ digits);

    return generate!({ return symbols.choice(rnd); }).take(length).to!string;
}
