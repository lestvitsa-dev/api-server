import hibernated.core;
import std.datetime;
import std.string : format;
import std.array : split;
import std.conv : to;

@Entity class Group
{
    @Generated long id;
    @Column string name;
    @Column string key;
    @OneToMany("group") User[] users;

    this()
    {
    }

    this(string name, string key)
    {
        this.name = name;
        this.key = key;
    }

    override string toString()
    {
        return "Group {%s, %s, %s}".format(id, name, key);
    }
}

@Entity class User
{
    @Generated long id;
    @Column string name;
    @Column string key;
    @ManyToOne @JoinColumn("group_fk") Group group;
    @OneToMany("owner") PrayerRequest[] prayerList;

    override string toString()
    {
        return "User {%s, %s, %s, %s, %s}".format(id, name, key, prayerList, group);
    }

    this()
    {
    }

    this(string name, string key)
    {
        this.name = name;
        this.key = key;
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
    ABOUT_DECEASED,
    ABOUT_LOST //о заблудших
}

enum Period
{
    FORTY_DAYS = "FORTY_DAYS",
    ONE_MONTH = "ONE_MONTH",
    SIX_MONTHS = "SIX_MONTHS",
    ONE_YEAR = "ONE_YEAR",
    ALWAYS = "ALWAYS",
    CUSTOM = "CUSTOM"
}

@Entity class PrayerRequest
{
    @Generated long id;

    @Column @Null string prescript;
    @Column @NotNull string name;
    @Column @Null string surname;

    @Column string common = "false";

    @Column @Null string prayerType = to!string(PrayerType.ABOUT_ALIVE);
    @Column @Null string readingPeriod = Period.FORTY_DAYS;
    @Column @Null Date created; //... = Date(2022, 6, 1)

    @ManyToOne @JoinColumn("owner_fk") User owner;

    override string toString()
    {
        return "PrayerRequest {%s, %s}".format(id, name);
    }

    this(string name)
    {
        this.name = name;
    }

    this(string prescript, string name, string surname, string common,
            string prayerType, string readingPeriod, string createdDate)
    {
        static foreach (field; ["prescript", "name", "surname", "common",
                "prayerType", "readingPeriod"])
        {
            mixin("this." ~ field ~ " = " ~ field ~ ";");
        }
        auto date = createdDate.split("-");
        this.created = Date(date[0].to!int, date[1].to!int, date[2].to!int);
    }

    this()
    {
    }
}
