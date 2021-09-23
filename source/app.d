import vibe.vibe;

final class WebChat
{
    private
    {
        RedisDatabase m_db;
        Room[string] m_rooms;
    }

    this()
    {
        m_db = connectRedis("127.0.0.1").getDatabase(0);
    }

    // ...

    // GET /
    void get()
    {
        render!"index.dt";
    }

    void getRoom(string id, string name)
    {
        auto messages = getOrCreateRoom(id).messages;
        render!("room.dt", id, name, messages);
    }

    void postRoom(string id, string name, string message)
    {
        if (message.length)
            getOrCreateRoom(id).addMessage(name, message);
        redirect("room?id=" ~ id.urlEncode ~ "&name=" ~ name.urlEncode);
    }

    private Room getOrCreateRoom(string id)
    {
        if (auto pr = id in m_rooms)
            return *pr;
        return m_rooms[id] = new Room(m_db, id);
    }

    // GET /ws?room=...&name=...
    void getWS(string room, string name, scope WebSocket socket)
    {
        auto r = getOrCreateRoom(room);

        auto writer = runTask({
            auto next_message = r.messages.length;

            while (socket.connected)
            {
                while (next_message < r.messages.length)
                    socket.send(r.messages[next_message++]);
                r.waitForMessage(next_message);
            }
        });

        while (socket.waitForData)
        {
            auto message = socket.receiveText();
            if (message.length)
                r.addMessage(name, message);
        }

        writer.join(); // wait for writer task to finish
    }
}

final class Room
{
    RedisDatabase db;
	string id;
	RedisList!string messages;
	LocalManualEvent messageEvent;

	this(RedisDatabase db, string id)
	{
		this.db = db;
		this.id = id;
		this.messages = db.getAsList!string("webchat_"~id);
		this.messageEvent = createManualEvent();
	}

	void addMessage(string name, string message)
	{
		messages.insertBack(name ~ ": " ~ message);
		messageEvent.emit();
	}

	void waitForMessage(long next_message)
	{
		while (messages.length <= next_message)
			messageEvent.wait();
	}

}

void main()
{
    // the router will match incoming HTTP requests to the proper routes
    auto router = new URLRouter;
    // registers each method of WebChat in the router
    router.registerWebInterface(new WebChat);
    // match incoming requests to files in the public/ folder
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    // for production installations, the error stack trace option should
    // stay disabled, because it can leak internal address information to
    // an attacker. However, we'll let keep it enabled during development
    // as a convenient debugging facility.
    //settings.options &= ~HTTPServerOption.errorStackTraces;
    listenHTTP(settings, router);
    logInfo("Please open http://127.0.0.1:8080/ in your browser.");

    runApplication();
}
