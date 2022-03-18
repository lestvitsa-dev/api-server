import hibernated.core;
import std.datetime;
import std.string : format;

class Group
{
    long id;
    string name;
    @OneToMany User[] users;

    public this()
    {
    }

    public this(string name)
    {
        this.name = name;
    }
}

class User
{
    long id;
    string name;
    string password;
    @ManyToOne Group group;

    override string toString()
    {
        return "[%s, %s, %s]".format(id, name, password);
    }
}

struct Reading
{
    int kathismaNumber;
    string userId;
}

struct Reminder
{
    int id;
    string userId;
    TimeOfDay time;
}

enum PrayerType
{
    ABOUT_ALIVE,
    ABOUT_DECEASED //о заблудших
}

enum Period
{
    FORTY_DAYS,
    ONE_MONTH,
    SIX_MONTHS,
    ONE_YEAR,
    ALWAYS
}

struct PrayerRequest
{
    //	int id;
    //	string userId;

    PrayerType type;
    Period reading;
    Date created;
    string prescript;
    string name;
    string surname;
}
