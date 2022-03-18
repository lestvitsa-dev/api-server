import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import ddbc.drivers.mysqlddbc;

import hibernated.core;

import model;

@path("api")
interface DataStore
{

    @method(HTTPMethod.GET)
    User getUser(string name);

    // The following curl command adds a user:
    // curl -X POST localhost:8080/api/add_user -H 'Content-Type: application/json' -d '{"name":"noname", "password":"secret", "groupId":1}'
    @method(HTTPMethod.POST)
    @path("add_user")
    long addUser(string name, string password, int groupId);
    
//    @method(HTTPMethod.POST)
//    @path("add_group")
//    long addGroup(string name);

    //    // GET /all_groups -> responds {"id": "...", "name": ...}
    //    Group[] getAllGroups();
    //
    // GET /all_users -> responds {"id": "...", "name": ... , ...}
    // curl localhost:8080/api/user/all
    @path("user/all")
    User[] getAllUsers();
    //
    //    User[] getUsersForGroup(string groupName);
    //
    //    string[] getPrayerListForUser(string userName);
    //
    //    string[] getPrayerListForGroup(string groupName);
    //
    //    void putUser(string name, string password, int groupId);
    //
    //    void addPrayerRequest(PrayerRequest p, Group g);

}

class DataStoreImpl : DataStore
{
    hibernated.session.Session sess;

    this(hibernated.session.Session hibernateSession)
    {
        this.sess = hibernateSession;
    }

    this()
    {
    }

    User getUser(string name)
    {
        // load and check data
        User u = sess.createQuery("FROM User WHERE name=:Name")
            .setParameter("Name", name).uniqueResult!User();
        return u;
    }

    long addUser(string name, string password, int groupId)
    {
        User newUser = new User();
        //        newUser.id = cast(int) users.length + 1;
        newUser.name = name;
        newUser.password = password;
        //        newUser.groupId = groupId;
        sess.save(newUser);
        return -1;
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
    User[] getAllUsers()
    {
        // read all users using query
        Query q = sess.createQuery("FROM User ORDER BY name");
        User[] list = q.list!User();
        return list;
    }
    
//     long addGroup(string name){
//     	sess.save(new Group(name));
//     	return -1;
//     }
    
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
    EntityMetaData schema = new SchemaInfoImpl!(User, Group);

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

    // use session to access DB
    auto dataStore = new DataStoreImpl(sess);

    auto router = new URLRouter;
    router.registerRestInterface(dataStore);

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);

    logInfo("Please open http://127.0.0.1:8080/ in your browser.");

    // create a client to talk to the API implementation over the REST interface
//    runTask({
//        auto client = new RestInterfaceClient!DataStore("http://127.0.0.1:8080/");
////        client.addUser("Vasya", "xCdgnbd3eos", 1);
////        client.addUser("Ivan", "xldLkDekn89", 1);
//        auto users = client.getAllUsers();
//        logInfo("Users: %s", users);
//    });

    runApplication();

}
