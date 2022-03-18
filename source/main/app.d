import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import model;

interface API
{

    // GET /all_groups -> responds {"id": "...", "name": ...}
    Group[] getAllGroups();

    // GET /all_users -> responds {"id": "...", "name": ... , ...}
    User[] getAllUsers();

    User[] getUsersForGroup(string groupName);

    string[] getPrayerListForUser(string userName);

    string[] getPrayerListForGroup(string groupName);

    void putUser(string name, string password, int groupId);

}

class APIImplementation : API
{
    private
    {
        User[] users;
        Group[] groups;
    }

    Group[] getAllGroups()
    {
        return groups;
    }

    User[] getAllUsers()
    {
        return users;
    }

    User[] getUsersForGroup(string groupName)
    {
        return [];
    }

    string[] getPrayerListForUser(string userName)
    {
        return [];
    }

    string[] getPrayerListForGroup(string groupName)
    {
        return [];
    }

    void putUser(string name, string password, int groupId)
    {
        User newUser;
//        newUser.id = cast(int) users.length + 1;
        newUser.name = name;
        newUser.password = password;
//        newUser.groupId = groupId;
        users ~= newUser;
    }

    bool checkPassword(string user, string password)
    {
        return user == "admin" && password == "secret";
    }
}

unittest
{
	//testAPI();

}

void testAPI()
{
	
    auto router = new URLRouter;
    router.registerRestInterface(new APIImplementation);

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    listenHTTP(settings, router);

    // create a client to talk to the API implementation over the REST interface
    runTask({
        auto client = new RestInterfaceClient!API("http://127.0.0.1:8080/");
        client.putUser("Vasya", "xCdgnbd3eos", 1);
        client.putUser("Vasya2", "xldLkDekn89", 1);
        auto users = client.getAllUsers();
        logInfo("Users: %s", users);
    });

    runApplication();
}
