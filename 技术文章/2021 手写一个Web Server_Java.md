## Web 服务器的基本实现

如果你使用过 Node.js 开发 Web 后端应用，那么一定使用过或者听说过 express，下面我们就来开发一个类似 express 风格的 Web 服务器框架。

### http 协议

首先是实现 http 协议。

先别着急害怕，我们只需要了解一丢丢，下面给出请求报文和响应报文的例子。

```http
GET /index/test HTTP/1.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Accept-Encoding: gzip, deflate, br
Accept-Language: zh-CN,zh;q=0.9,sq;q=0.8
Connection: keep-alive
Host: localhost
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36
```

第一行是请求行，分别用空格分割了三个部分：method、url、protocol

后面是请求头，最后再空一行，写请求体，只不过这个实例没有请求体。

```http
HTTP/1.1 200
Content-Type: text/html

<h1> Hello, web Framework! </h1>
```

第一行是响应行，分别用空格分割了两个部分：protocol 和 status

接下来是响应头，这里只有一个 Content-Type，最后空一行，再写响应体，可以看到，这里的响应体是 html 代码。

### 立刻实现

有了这些，我们就可以花几行代码，立刻实现一个简单的 Web 服务器。

看好了。

要知道，所有网络通信均基于 TCP/IP 协议，而该协议的实现就是一个被称为 socket 的东西，几乎任何操作系统都对上层提供了 socket 的接口，很多编程语言的标准库也对这些系统调用做了封装。

在 Java 中，我们只需要这样做，就能创建一个服务端 Socket，并监听 80 端口：

```java
ServerSocket serverSocket = new ServerSocket(80);
```

然后呢，Web 服务器在入口处从不拒绝任何连接，我们要接收所有的 socket 请求：

`accept` 方法将阻塞当前程序，直到下一个 socket 连接请求到来，然后建立一个长连接。

```java
while (true) {
     Socket client = serverSocket.accept();
}
```

当我们成功建立一个 socket 连接，此时我们先不关注请求报文，而是直接对它发送一个 http 响应报文：

我们先调用 `write` 向对方写一些数据，`flush` 将强行写出所有数据，最后调用 `close` 关闭这个链接（http 是无状态的，如果不主动关闭该连接，客户端将认为此次请求并未结束）。

```java
while (true) {
    Socket client = serverSocket.accept();

    OutputStream clientOutStream = client.getOutputStream();
    clientOutStream.write(
       ("HTTP/1.1 200\n"
      + "Content-Type: text/html\n"
      + "\n"
      + "<h1> Hello, web Framework! </h1>").getBytes()
    );
    clientOutStream.flush();
    clientOutStream.close();
}
```

这就结束了，所有代码：

```java
import java.io.IOException;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;

public class Main {
    public static void main(String[] args) {
        try {
            ServerSocket serverSocket = new ServerSocket(80);
            while (true) {
                Socket client = serverSocket.accept();

                OutputStream clientOutStream = client.getOutputStream();
                clientOutStream.write(
                        ("HTTP/1.1 200\n"
                                + "Content-Type: text/html\n"
                                + "\n"
                                + "<h1> Hello, web Framework! </h1>").getBytes()
                );
                clientOutStream.flush();
                clientOutStream.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

现在运行这个 Java 程序，然后用浏览器请求本地的 80 端口，你将看到：

![](https://cdn.jsdelivr.net/gh/lovemiaow/noteImages@master/2024/01/2024012901.png)

## Web 框架的基本实现

到这里，实际上我要表达的所有思想已经全部说清楚了，tomcat 底层就是做了这些事情，接收 socket 连接，然后发送报文，只不过在这中间他还调用了开发者的 Servlet 实现类 —— 因为它需要知道到底应该发送什么内容的报文。

下面的内容是这中间的部分的简单实现，如果你对如何简单地分析请求报文，如何设计一个简单的回调机制感兴趣，可以继续看下去。

如果你有 Java Web 开发基础，那一定知道 web.xml 这个东西，这也是 Servlet 相关规范的一环，他提示 Web 服务器应该如何理解我们的 web 应用配置。

例如路由（或者叫 url）对应的处理程序，需要配置 servlet-mapping，我认为这并不是一种好的设计。

好的设计应该让框架提供足够的自由度，尽量少用配置，把逻辑尽量体现在代码里。

但这也存在 Java Web 本身依赖关系的限制，如果启动入口是我们的程序，这种关系下设计的框架就很容易实现足够的自由度，但如果入口本身就在框架中，那么框架的设计将比较受限。

### 框架设计

下面要设计一个 express like 的框架，我们将不把框架作为程序的入口，而是在其他程序中引用该框架编写业务代码。

他使用起来就像这样：

```java
Entrance app = new Entrance();

app.use("/test", (req, res) -> {
    res.setStatus(200)
        .setHeaders("Content-Type", "text/html")
        .send("<h1> Hello, web framework! </h1>");
});

app.listen(80);
```

仓库 --> 

该框架将存在一个入口类 `Entrance`，该类实例化的对象将作为一个独立的 web 服务。

`use` 方法将一个回调方法注册到一个路由上，`listen` 方法用来开始监端口。

### 入口类

我们先来实现入口类的 `listen` 方法，`listen` 用来不断建立 socket 连接，并向客户端（浏览器）发送数据：

```java
public class Entrance {
    public void listen(int port) {
        try {
            // 监听 port 端口
            ServerSocket serverSocket = new ServerSocket(port);
            while (true) {
                // 接受连接
                Socket client = serverSocket.accept();

                // 创建新线程，发送数据
                new Thread(() -> {
                    try {
                        OutputStream clientOutStream = client.getOutputStream();
                        clientOutStream.write(
                                ("HTTP/1.1 200\n"
                                        + "Content-Type: text/html\n"
                                        + "\n"
                                        + "<h1> Hello, web Framework! </h1>").getBytes()
                        );
                        clientOutStream.flush();
                        clientOutStream.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }).start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

> 注意这里对每个 socket 请求都创建了一个新线程处理，用来提高并发性能。

这时候我们就可以这样写：

```java
Entrance app = new Entrance();
app.listen(80);
```

![](https://cdn.jsdelivr.net/gh/lovemiaow/noteImages@master/2024/01/2024012901.png)

然后我们要实现一个另一个方法 `use`，注册一个回调方法到某个路由：

为了记录路由到回调方法的映射，我们使用一个哈希表：

```java
private final HashMap<String, Processor> routeMap = new HashMap();
```

然后在开发者调用 `use` 时记录这个映射关系：

```java
public void use(String route, Processor processor) {
    routeMap.put(route, processor);
}
```

`Processor` 是回调方法的函数式类型，正常来讲，应该接收一个 request 参数和一个 response 参数。

这时候可以回头改一下 `listen` 中的 while，不要再回复固定内容了，而是向不同路由的回调方法分发消息：

```java
while (true) {
    // 接受连接
    Socket client = serverSocket.accept();

    // 创建新线程，发送数据
    new Thread(() -> {
        try {
            // 分发消息
            Request request = new Request(client.getInputStream());
            Response response = new Response(client.getOutputStream());
            if (routeMap.containsKey(request.getUrl())) {
                routeMap.get(request.getUrl()).callback(request, response);
            } else {
                response.setStatus(404).send(request.getUrl() + " not found");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }).start();
}
```

到现在为止，入口类 `Entrance` 的代码就已经全部完成了：

```java
package com.mrliu.webserver;

import java.io.IOException;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.HashMap;


public class Entrance {
    private final HashMap<String, Processor> routeMap = new HashMap();

    public void use(String route, Processor processor) {
        routeMap.put(route, processor);
    }
    public void listen(int port) {
        try {
            // 监听 port 端口
            ServerSocket serverSocket = new ServerSocket(port);
            while (true) {
                // 接受连接
                Socket client = serverSocket.accept();

                // 创建新线程，发送数据
                new Thread(() -> {
                    try {
                        OutputStream clientOutStream = client.getOutputStream();
                        clientOutStream.write(
                                ("HTTP/1.1 200\n"
                                        + "Content-Type: text/html\n"
                                        + "\n"
                                        + "<h1> Hello, web Framework! </h1>").getBytes()
                        );
                        clientOutStream.flush();
                        clientOutStream.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }).start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

```

`Request`、`Response` 就是刚才 `Processor` 需要接收的参数，下面我们来实现这些类型。

### 回调方法

`Processor` 非常简单，他就是一个函数式接口：

```java
package com.mrliu.webserver;

@FunctionalInterface
public interface Processor {
    void callback(Request request, Response response);
}
```

### 解析请求报文

`Request` 负责解析请求报文，在这里，我们仅解析 url、GET 请求的 params 和 method，我们创建对应的属性和访问器：

```java
private String url;
private String params;
private String method;

public String getUrl() {
    return url;
}

public String getParams() {
    return params;
}

public String getMethod() {
    return method;
}
```

可以看到，在入口类中，我们将 socket 的输入流作为构造参数进行实例化，所以构造函数如下：

我们把请求行 "GET /test HTTP/1.1" 通过空格分割，分别得到了 method、fullUrl，在 url 中又通过 "?" 得到了 url 和 params。

```java
public Request(InputStream inputStream){
    try {
        String[] requestLine =  new BufferedReader(new InputStreamReader(inputStream)).readLine().split(" ");
        if (requestLine.length == 3 && requestLine[2].equals("HTTP/1.1")) {
            this.method = requestLine[0];
            String fullUrl = requestLine[1];
            if (fullUrl.contains("?")) {
                this.url = fullUrl.substring(0, fullUrl.indexOf("?"));
                this.params = fullUrl.substring(fullUrl.indexOf("?") + 1);
            } else {
                this.url = fullUrl;
            }
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

`Request` 这就完成了，完整代码如下：

```java
package com.mrliu.webserver;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class Request {

    private String url;
    private String params;
    private String method;

    public Request(InputStream inputStream){
        try {
            String requestLineStr =  new BufferedReader(new InputStreamReader(inputStream)).readLine();
            if(requestLineStr == null) {
                this.url = "";
                this.params = "";
                this.method = "";
                return;
            }
            String[] requestLine = requestLineStr.split(" ");
            if (requestLine.length == 3 && requestLine[2].equals("HTTP/1.1")) {
                this.method = requestLine[0];
                String fullUrl = requestLine[1];
                if (fullUrl.contains("?")) {
                    this.url = fullUrl.substring(0, fullUrl.indexOf("?"));
                    this.params = fullUrl.substring(fullUrl.indexOf("?") + 1);
                } else {
                    this.url = fullUrl;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public String getUrl() {
        return url;
    }

    public String getParams() {
        return params;
    }

    public String getMethod() {
        return method;
    }
}
```

### 响应客户端

在 `Response` 类中，我们需要给开发者提供设置请求头、设置响应状态吗和响应数据的能力：

对于设置请求头，我们使用一个哈希表来存，响应数据时再拼接：

```java
private HashMap<String, String> headers = new HashMap<>();
public Response setHeaders(String key, String value) {
    this.headers.put(key, value);
    return this;
}
```

对于响应状态码，我们这样实现：

```java
private int status;
public Response setStatus(int statusCode) {
    this.status = statusCode;
    return this;
}
```

在这里，我们还要将输出流放在内部维护：

```java
private OutputStream outputStream;
```

构造函数则是直接初始化输出流：

```java
public Response(OutputStream outputStream) {
    this.outputStream = outputStream;
}
```

最后一个功能，发送数据，实际上是向输出流中写字符串：

在这个方法中，我们让开发者提供请求体的字符串内容。

```java
public void send(String data) {
    try {
        StringBuilder dataBuilder = new StringBuilder();

        // 拼接请求行
        dataBuilder.append("HTTP/1.1 ").append(this.status).append("\n");

        // 拼接请求头
        for (String key:
             this.headers.keySet()) {
            dataBuilder.append(key).append(": ").append(this.headers.get(key)).append("\n");
        }

        // 拼接请求体
        dataBuilder.append("\n").append(data);

        outputStream.write(dataBuilder.toString().getBytes());
        outputStream.flush();
        outputStream.close();
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

到这里 `Response` 也实现完毕了，代码如下：

```java
package com.mrliu.webserver;

import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;

public class Response {
    private OutputStream outputStream;
    private HashMap<String, String> headers = new HashMap<>();
    private int status;

    public Response(OutputStream outputStream) {
        this.outputStream = outputStream;
    }

    public Response setHeaders(String key, String value) {
        this.headers.put(key, value);
        return this;
    }

    public Response setStatus(int statusCode) {
        this.status = statusCode;
        return this;
    }

    public void send(String data) {
        try {
            StringBuilder dataBuilder = new StringBuilder();
            dataBuilder.append("HTTP/1.1 ").append(this.status).append("\n");
            for (String key:
                    this.headers.keySet()) {
                dataBuilder.append(key).append(": ").append(this.headers.get(key)).append("\n");
            }
            dataBuilder.append("\n").append(data);

            outputStream.write(dataBuilder.toString().getBytes());
            outputStream.flush();
            outputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

### 测试

现在我们有一个入口类 `Entrance`，其每一个实例都是一个独立的 Web 服务端。

还有一个回调方法的函数式类型 `Processor`，用来通过 `use` 方法接入框架的处理流程，还有与之相关的 `Request` 和 `Response` 类型，用来解析请求报文和提供开发者响应客户端的能力。

现在你可以随意测试这个框架，就像这样：

```java
import com.mrliu.webserver.Entrance;

public class Main {
        public static void main(String[] args) {
            Entrance app = new Entrance();
            app.use("/test", (req, res) -> {
                res.setStatus(200)
                        .setHeaders("Content-Type", "text/html")
                        .send("<h1> Hello, web framework! </h1>");
            });

            app.listen(80);
        }
}

```

由于笔者没有基本的 Java 功底，对一些机制并不了解，目前这个框架偶然会玄学地在线程中抛出 `NullPointerException` 异常，在异常的栈轨迹中也没有触发任何断点。

## Java Web 服务器的基本实现

这里的 Java Web 服务器指符合 Servlet 规范的 Web 服务器。然而实际上其体系规模略庞大，我们不可能简单地实现它，但我们可以自己定义一个 Servlet 类似的简单规范，然后去尝试实现。这样可以搞明白 tomcat 这种服务器到底在实现什么，以及他可以如何实现这些东西。



