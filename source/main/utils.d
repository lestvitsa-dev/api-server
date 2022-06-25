module utils;

/** Возвращает строку из случайно выбранных латинских букв и цифр
длины length
*/
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
