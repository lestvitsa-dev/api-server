import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;
import ddbc.drivers.mysqlddbc;
import hibernated.core;
import std.stdio : writeln;
import std.datetime;
import model;

alias hibernated.session.Session Session;

@path("api")
interface DataStore
{

    @method(HTTPMethod.GET)
    User getUser(string key);

    // GET /all_users -> responds {"id": "...", "name": ... , ...}
    // curl localhost:8080/api/user/all
    @path("user/all")
    User[] getAllUsers();

    // The following curl command adds a user:
    // curl -X POST localhost:8080/api/add_user -H 'Content-Type: application/json' -d '{"name":"noname", "key":"secret", "groupId":1}'
    @method(HTTPMethod.POST)
    @path("add_user")
    long addUser(string name, string key, int groupId);

    // GET /all_groups -> responds {"id": "...", "name": ...}
    @path("group/all")
    Group[] getAllGroups();

    @method(HTTPMethod.POST)
    @path("add_group")
    long addGroup(string name, string key);

    long addPrayerRequest(string userKey, string prescript, string name, string surname,
            string common, string prayerType, string readingPeriod, string createdDate);

    PrayerRequest[] getPrayerListForUser(string userKey);

    PrayerRequest[] getPrayerListForGroup(string groupKey);

    PrayerRequest getPrayerRequest(long key);

    //
    //    User[] getUsersForGroup(string groupName);
    //
    //
    //
    //    void putUser(string name, string password, int groupId);
    //
    //    void addPrayerRequest(PrayerRequest p, Group g);

}

class DataStoreImpl : DataStore
{
    Session sess;

    this(Session hibernateSession)
    {
        this.sess = hibernateSession;
    }

    User getUser(string key)
    {
        // load and check data
        User[] list = sess.createQuery("FROM User WHERE key=:Key")
            .setParameter("Key", key).list!User();
        if (list.length == 0)
            return null;
        User user = list[0];
        logInfo("User: %s", user);

        return user;
    }

    User[] getAllUsers()
    {
        // read all users using query
        Query q = sess.createQuery("FROM User ORDER BY name");
        User[] list = q.list!User();
        return list;
    }

    long addUser(string name, string key, int groupId)
    {
        User newUser = new User();
        //        newUser.id = cast(int) users.length + 1;
        newUser.name = name;
        newUser.key = key;
        //        newUser.groupId = groupId;
        sess.save(newUser);
        return newUser.id;
    }

    //    private
    //    {
    //        User[] users;
    //        Group[] groups;
    //    }

    //    Group[] getAllGroups()
    //    {
    //        return groups;
    //    }
    //

    Group[] getAllGroups()
    {
        Query q = sess.createQuery("FROM Group ORDER BY name");
        return q.list!Group();
    }

    long addGroup(string name, string key)
    {
        Group g = new Group();
        g.name = name;
        g.key = key;
        sess.save(g);
        return g.id;
    }

    long addPrayerRequest(string userKey, string prescript, string name, string surname,
            string common, string prayerType, string readingPeriod, string createdDate)
    {
        User user = getUser(userKey);
        PrayerRequest prayerRequest = new PrayerRequest(prescript, name,
                surname, common, prayerType, readingPeriod, createdDate);
        prayerRequest.owner = user;
        logInfo("prayerRequest = %s", prayerRequest);

        sess.save(prayerRequest);

        return prayerRequest.id;
    }

    PrayerRequest[] getPrayerListForUser(string userKey)
    {
        User[] list = sess.createQuery("FROM User WHERE key=:Key")
            .setParameter("Key", userKey).list!User();
        if (list.length == 0)
            return [];
        User user = list[0];
        logInfo("PrayerList: %s", user.prayerList);

        return user.prayerList;
    }

    PrayerRequest[] getPrayerListForGroup(string groupKey)
    {
        return [];
    }

    PrayerRequest getPrayerRequest(long id)
    {
        PrayerRequest[] list = sess.createQuery("FROM PrayerRequest WHERE id=:Id")
            .setParameter("Id", id).list!PrayerRequest();

        return list[0];
    }

    //
    //    User[] getUsersForGroup(string groupName)
    //    {
    //        return [];
    //    }
    //
    //    string[] getPrayerListForUser(string userName)
    //    {
    //        return [];
    //    }
    //
    //    string[] getPrayerListForGroup(string groupName)
    //    {
    //        return [];
    //    }
    //
    //    bool checkPassword(string user, string password)
    //    {
    //        return user == "admin" && password == "secret";
    //    }
}

/*
void confORM()
{

    // remove reference
    u11.roles = u11.roles().remove(0);
    sess.update(u11);

    // remove entity
    sess.remove(u11);
}*/

void main()
{
    // create metadata from annotations
    EntityMetaData schema = new SchemaInfoImpl!(User, Group, PrayerRequest);

    // setup DB connection factory
    MySQLDriver driver = new MySQLDriver();
    string url = MySQLDriver.generateUrl("localhost", 3306, "api_db");
    string[string] params = MySQLDriver.setUserAndPassword("api", "LestvitsaDev");
    Dialect dialect = new MySQLDialect();

    DataSource ds = new ConnectionPoolDataSourceImpl(driver, url, params);

    // create session factory
    SessionFactory factory = new SessionFactoryImpl(schema, dialect, ds);
    scope (exit)
        factory.close();

    // Create schema if necessary
    {
        // get connection
        Connection conn = ds.getConnection();
        scope (exit)
            conn.close();
        // create tables if not exist
        factory.getDBMetaData().updateDBSchema(conn, false, true);
    }

    // Now you can use HibernateD

    // create session
    hibernated.session.Session sess = factory.openSession();
    scope (exit)
        sess.close();

    /////////////////////////////////////////////////////
    //    // create sample data
    //    PrayerRequest pr1 = new PrayerRequest();
    //    pr1.name = "Ioann";
    //    PrayerRequest pr2 = new PrayerRequest();
    //    pr2.name = "Lidiya";
    //    Group g1 = new Group("Group1", "402jgh255");
    //    User u1 = new User("User1", "1234567890");
    //    u1.prayerList = [pr1, pr2];
    //    pr1.owner = u1;
    //    pr2.owner = u1;
    //    u1.group = g1;
    //
    //    sess.save(g1);
    //    sess.save(u1);
    //    sess.save(pr1);
    //    sess.save(pr2);
    //
    //    writeln(u1);
    //    // load and check data
    //    User u11 = sess.createQuery("FROM User WHERE name=:Name")
    //        .setParameter("Name", "User1").list!User()[$ - 1];
    //
    //    writeln(u11);
    /////////////////////////////////////////////////////

    // use session to access DB
    auto dataStore = new DataStoreImpl(sess);

    auto router = new URLRouter;
    router.registerRestInterface(dataStore);

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);

    logInfo("Server started on http://127.0.0.1:8080/");

    addSampleDataToDB();

    runApplication();

}

private void addSampleDataToDB()
{
    version (SERVER_CONNECTION_1)
    {
        // create a client to talk to the API implementation over the REST interface
        runTask({
            auto client = new RestInterfaceClient!DataStore("http://127.0.0.1:8080/");
            client.addUser("Vasya", "xCdgnbd3eos", 1);
            client.addUser("Ivan", "xldLkDekn89", 1);
            auto users = client.getAllUsers();
            logInfo("Users: %s", users);
        });
    }
    version (SERVER_CONNECTION_2)
    {
        runTask({
            auto client = new RestInterfaceClient!DataStore("http://127.0.0.1:8080/");
            long i = client.addPrayerRequest();
            logInfo("client.addPrayerRequest() returns %s", i);
        });
    }
}
