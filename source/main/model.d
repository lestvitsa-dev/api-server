import std.datetime;

struct Group
{
	string id;
	string name;
}

struct User
{
	string id;
	string name;
	string password;
	string groupId;
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
	FOR_ALIVE, FOR_DECEASED
}

struct UserPrayerRequest
{
	int id;
	string userId;
	string name;
	string surname;
	PrayerType type;
	Date created;
	
}

struct GroupPrayerRequest
{
	int id;
	string groupId;
	string name;
	PrayerType type;
	Date date;	
}

