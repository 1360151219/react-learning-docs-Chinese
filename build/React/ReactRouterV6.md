# React Router v6 中文

## 前言

最近学习 React，但是 React 的路由最新版本 v6 却只有英文官方文档，中文文档已经旧得不能再旧了。因此打算边学习边简单翻译下官方文档吧

文档也被部署到了另一个域名中 http://react.strk2.cn

## Get Started 开始教程

### Installation 下载

```bash
pnpm add react-router-dom@6 --save
```

### Connect the URL 将 App 与 URL 连接

文档中使用`BrowserRouter`来渲染你的整个 App 应用。（histroy 模式，hash 模式则是`HashRouter`

```js
import { render } from "react-dom";
import { BrowserRouter } from "react-router-dom";
import App from "./App";

const rootElement = document.getElementById("root");
render(
  <BrowserRouter>
    <App />
  </BrowserRouter>,
  rootElement
);
```

### Add some Links 使用 Link 组件

通过`Link`来进行路由的跳转，

- `to`：指定跳转的 url，可以是相对路径（基于父 Route 进行继承）

```js
<Route path="/" element={<App />}>
  <Link to="demo">To Demo</Link> // to '/demo'
</Route>
```

### Add some Routes 使用 Route 组件

通过`Route`组件来根据 url 来进行对应组件的渲染

- `path`：对应的 url
- `element`：将要渲染的组件

```js
<Route path="/" element={<App />} />
```

### Nested Routes 嵌套路由

完成嵌套路由只需要两步：

- Nest the routes inside of the App route 将子`Route`嵌套在父`Route`之中

Right now the _expenses_ and _invoice_ routes are siblings to the app, we want to make them children of the app route:

```js
<BrowserRouter>
    <Routes>
      <Route path="/" element={<App />}>
        <Route path="expenses" element={<Expenses />} />
        <Route path="invoices" element={<Invoices />} />
      </Route>
    </Routes>
  </BrowserRouter>,
```

- 渲染`Outlet`组件

```js
// at App.js
<Link to="/invoices">Invoices</Link>
<Link to="/expenses">Expenses</Link>
<Outlet />
```

### Listing the Invoices

模仿一段后端数据并且像这样写出以下代码：

```js
// src/data.js
let invoices = [
  {
    name: "Santa Monica",
    number: 1995,
    amount: "$10,800",
    due: "12/05/1995",
  },
  {
    name: "Stankonia",
    number: 2000,
    amount: "$8,000",
    due: "10/31/2000",
  },
  {
    name: "Ocean Avenue",
    number: 2003,
    amount: "$9,500",
    due: "07/22/2003",
  },
  {
    name: "Tubthumper",
    number: 1997,
    amount: "$14,000",
    due: "09/01/1997",
  },
  {
    name: "Wide Open Spaces",
    number: 1998,
    amount: "$4,600",
    due: "01/27/1998",
  },
];

export function getInvoices() {
  return invoices;
}

// /invoices.jsx
import { Link } from "react-router-dom";
import { getInvoices } from "../data";

export default function Invoices() {
  let invoices = getInvoices();
  return (
    <div style={{ display: "flex" }}>
      <nav
        style={{
          borderRight: "solid 1px",
          padding: "1rem",
        }}
      >
        {invoices.map((invoice) => (
          <Link
            style={{ display: "block", margin: "1rem 0" }}
            to={`/invoices/${invoice.number}`}
            key={invoice.number}
          >
            {invoice.name}
          </Link>
        ))}
      </nav>
    </div>
  );
}
```

可以发现点击`Link`后路径跳转却不能匹配到对应路由组件。

### Adding a No-Match Route 添加一个没有匹配成功的路由组件

事情并不像你想象的那样。如果您点击这些链接，页面将变为空白!这是因为我们定义的路由中没有一个匹配我们所链接的 URL: `"/invoice/123"`。

在我们继续之前，最好总是处理这种“不匹配”的情况。回到你的路由配置，添加以下内容:

```js
<Route
  path="*"
  element={
    <main style={{ padding: "1rem" }}>
      <p>There's nothing here!</p>
    </main>
  }
/>
```

这里的`path`被赋予了`*`，表示当没有其他路由匹配的时候，就匹配这个。**与顺序无关**

### Read URL Params 读取 URL 参数 `useParmas`

我们刚刚匹配到了 `"/invoices/1998"` and `"/invoices/2005"`, 我们现在想要在具体的组件中去获取这个 url 的参数。比如：

```js
// invoice.jsx
export default function Invoice() {
  return <h2>Invoice #???</h2>;
}
```

此时我们需要在`Invoices`组件中去添加一个嵌套组件，而且使用动态路由：

```js
<Route path="invoices" element={<Invoices />}>
  <Route path=":invoiceId" element={<Invoice />} />
</Route>
```

有几件事情需要注意：

- 我们刚刚创建了一个匹配像`“/invoices/2005”`和`“/invoices/1998”`这样的 url 路由。路径的`:invoiceId` 部分是一个`“URL 参数”`，这意味着只要模式相同，它就可以匹配任何值。

- 嵌套路由是可以再次被嵌套的：`<App><Invoices><Invoice /></Invoices></App>`

之后我们还需要在 `Invoices`中去添加一个`Outlet`组件。

现在我们就可以开始来获取这个动态 invoiceid 参数了。

```js
import { useParams } from "react-router-dom";

export default function Invoice() {
  let params = useParams();
  return <h2>Invoice: {params.invoiceId}</h2>;
}
```

要注意的是，这是一个 HOOK API，无法在类组件中使用。

有了这个参数，我们就可以使用它干一些有趣的事情啦。这里值得注意的是，url params 获取的是**字符串形式**的参数，而 data 中的是 Number 类型

```js
// src/data.js
export function getInvoice(id) {
  return invoices.find((invoice) => {
    return invoice.number == id;
  });
}
// invoice.jsx
export default function Invoice() {
  let params = useParams();
  let invoice = getInvoice(params.invoiceid);
  return (
    <div style={{ flex: 1, textAlign: "center" }}>
      <h1>Params contains invoices:{params.invoiceid}</h1>
      <p>Name:{invoice.name}</p>
      <p>Amount:{invoice.amount}</p>
      <p>Due:{invoice.due}</p>
    </div>
  );
}
```

### Index Router 索引路由

Index Router 很可能是最难让人们去理解的一个概念了。所以如果你曾困扰于此，我希望以下内容可以帮到你。

现在你看一下 Invoices 路由，在你还没有去点击 Invoice Link 的时候，你应该注意到内容区域是空白的，这很不友好，我们可以利用`index`路由来 fix 它。

```js
<Route path="invoices" element={<Invoices />}>
  <Route
    index
    element={
      <main style={{ padding: "1rem" }}>
        <p>Select an invoice</p>
      </main>
    }
  />
  <Route path=":invoiceId" element={<Invoice />} />
</Route>
```

你应该注意到索引路由是**没有`path`属性**的。

> 再注意一点，索引路由也没有`children`属性，即没有子路由

可以你仍然还抓破头脑没弄清楚，这里有一些我们尝试回答'索引路由是什么的'这个问题的答案，希望有一些能帮到你：

- 处于父路由组件中的索引路由作为父路由路径的出口 outlet
- 当匹配到父路由路径但其他子路由组件无一匹配时，匹配索引路由
- 索引路由是一个默认子路由
- 当用户还没点击子导航列表的时候，渲染索引路由

### Active Links 被激活的 Link 组件

去展示一个被激活的、用户正在看的 Link 是一个非常普遍的一个需求，尤其是在一个导航列表中。让我们使用`NavLink`来给 Invoices 列表加上这个效果。

```js
{
  invoices.map((invoice) => (
    <NavLink
      style={({ isActive }) => {
        return {
          display: "block",
          margin: "1rem 0",
          color: isActive ? "red" : "",
        };
      }}
      to={`/invoices/${invoice.number}`}
      key={invoice.number}
    >
      {invoice.name}
    </NavLink>
  ));
}
```

这里我们做了三件事情：

1. 我们将`Link`换成了`NavLink`
2. 我们将一个简单的 style 对象换成一个函数
3. 这个 style 函数接收一个参数(`isActive`)，当此时路由匹配的时候，`isActive`变为 true

我们也可以给`className`做同样的事情：

```js
// normal string
<NavLink className="red" />

// function
<NavLink className={({ isActive }) => isActive ? "red" : "blue"} />
```

### 查询字符串参数 `useSearchParams`

查询字符串跟 url 参数并不相同。你肯定在一些网站上看过比如`"/login?success=1" or "/shoes?brand=nike&sort=asc&sortby=price"`

React Router 通过`useSearchParams`方法让读取并操作查询字符串变得简单。**它像`React.useState()`作用相似，但它将状态存储在了 url 查询字符串中而不是内存中。**

下面我们给 Invoices 导航列表加一个小小的过滤功能吧

```js
export default function Invoices() {
  let invoices = getInvoices();
  let [searchParams, setSearchParams] = useSearchParams();
  return (
    <div style={{ display: "flex" }}>
      <nav
        style={{
          borderRight: "solid 1px",
          padding: "1rem",
        }}
      >
        <input
          value={searchParams.get("filter") || ""}
          onChange={(event) => {
            let filter = event.target.value;
            if (filter) {
              setSearchParams({ filter });
            } else {
              setSearchParams({});
            }
          }}
        />
        {invoices
          .filter((invoice) => {
            let filter = searchParams.get("filter");
            if (!filter) return true;
            let name = invoice.name.toLowerCase();
            return name.startsWith(filter.toLowerCase());
          })
          .map((invoice) => (
            <NavLink
              style={({ isActive }) => ({
                display: "block",
                margin: "1rem 0",
                color: isActive ? "red" : "",
              })}
              to={`/invoices/${invoice.number}`}
              key={invoice.number}
            >
              {invoice.name}
            </NavLink>
          ))}
      </nav>
      <Outlet />
    </div>
  );
}
```

- `setSearchParams()`可以将`?filter=...`放到 url 中并且重新渲染该路由。
- `useSearchParams`现在返回一个带有`filter`的`URLSearchParams`对象。
- 我们将 input 中的值设置到了 url search param 中
- 我们对 Invoices 列表基于 filter 进行了过滤。

### 自定义行为

如果你进行了过滤之后点击某个 Link，你会发现原本处于过滤状态的列表和 url 都会复原。现在我想要保持这个过滤状态，应该怎么做呢？

我们可以在点击 Link 的时候保持这个查询字符串通过将它加入 Link href 中。我们将通过组合`NavLink`和`useLocation`到一个新组件`QueryNavLink`中。

```js
import { useLocation, NavLink } from "react-router-dom";

function QueryNavLink({ to, ...props }) {
  let location = useLocation();
  return <NavLink to={to + location.search} {...props} />;
}
```

然后在`src/Invoices.jsx`中用`QueryNavLink`替换掉`NavLink`就 OKK 啦。

`useLocation()`返回一个 url location 对象，告诉我们更多的 URL 信息：

```js
{
  pathname: "/invoices",
  search: "?filter=sa",
  hash: "",
  state: null,
  key: "ae4cz2j"
}
```

有了这些信息，`QueryNavLink`的任务就很简单啦：将`location.search`拼接到`to`属性后面。你可能会想：天啊，这似乎应该是 React Router 或什么的内置组件? 让我们来看一下另外一个例子：

假设现在你有这些`Link`在一个电子贸易网站上：

```js
<Link to="/shoes?brand=nike">Nike</Link>
<Link to="/shoes?brand=vans">Vans</Link>
```

然后你想要当 URL 比配到相应的 brand 的时候，装饰对应的`Link`。那你就可以像之前学到的那样自己写一个组件：

```js
function BrandLink({ brand, ...props }) {
  let [params] = useSearchParams();
  let isActive = params.getAll("brand").includes(brand);
  return (
    <Link
      style={{ color: isActive ? "red" : "" }}
      to={`/shoes?brand=${brand}`}
      {...props}
    />
  );
}
```

现在 active 能在`"/shoes?brand=nike"`或者`"/shoes?brand=nike&brand=vans"`中被激活。但你可能只想让 active 在只选择了一个 brand 的时候被激活。

```js
let brands = params.getAll("brand");
let isActive = brands.includes(brand) && brands.length === 1;
// ...
```

或者你可能想要将`Link`变得能添加的。

```js
function BrandLink({ brand, ...props }) {
  let [params] = useSearchParams();
  let isActive = params.getAll("brand").includes(brand);
  if (!isActive) {
    params.append("brand", brand);
  }
  return (
    <Link
      style={{ color: isActive ? "red" : "" }}
      to={`/shoes?${params.toString()}`}
      {...props}
    />
  );
}
```

或者你想要当 brand 不存在的时候添加，而当 brand 存在的时候，再次点击可以删除它

```js
function BrandLink({ brand, ...props }) {
  let [params] = useSearchParams();
  let isActive = params.getAll("brand").includes(brand);
  if (!isActive) {
    params.append("brand", brand);
  } else {
    params = new URLSearchParams(
      Array.from(params).filter(
        ([key, value]) => key !== "brand" || value !== brand
      )
    );
  }
  return (
    <Link
      style={{ color: isActive ? "red" : "" }}
      to={`/shoes?${params.toString()}`}
      {...props}
    />
  );
}
```

正如您所看到的，即使在这个相当简单的示例中，也有许多您可能想要的有效行为。React Router 不会尝试直接解决我们听说过的所有用例。相反，我们提供组件和钩子来组合您需要的任何行为。

### 编程式导航

Okay，回到我们的 App 中，坚持一下你就快学完了。

大多数情况下我们的 URL 变化都是通过用户去点击`Link`，但有的时候，作为程序员想要去改变 URL。一个非常常见的场景是在数据更新之后，比如创建或删除记录。

让我们添加一个按钮用来标记对应的 Invoice、然后导航到索引路由。

首先你可以 copy and paste 这个函数。

```js
export function deleteInvoice(number) {
  invoices = invoices.filter((invoice) => invoice.number !== number);
}
```

现在可以添加这个删除按钮，调用引入的新函数，然后跳转到索引路由中啦。

```js
import { useParams, useNavigate, useLocation } from "react-router-dom";
import { getInvoice, deleteInvoice } from "../data";

export default function Invoice() {
  let navigate = useNavigate();
  let location = useLocation();
  let params = useParams();
  let invoice = getInvoice(parseInt(params.invoiceId, 10));

  return (
    <main style={{ padding: "1rem" }}>
      <h2>Total Due: {invoice.amount}</h2>
      <p>
        {invoice.name}: {invoice.number}
      </p>
      <p>Due Date: {invoice.due}</p>
      <p>
        <button
          onClick={() => {
            deleteInvoice(invoice.number);
            navigate("/invoices" + location.search);
          }}
        >
          Delete
        </button>
      </p>
    </main>
  );
}
```

这里用到了`useNavigate()`。它返回一个函数，通过传入要跳转的 url 来实现编程式导航。

## 路由懒加载 React.lazy

```jsx
const OtherComponent = React.lazy(() => import("./OtherComponent"));
```

`React.lazy`接收一个函数，这个函数需要动态调用`import()`，它必须返回一个`Promise`，该`Promise`需要 resolve 一个 React 组件

然后要在`Suspense`组件中渲染 lazy 组件，这样我们可以在`Suspense`中做优雅降级。

```js
import React, { Suspense } from "react";

const OtherComponent = React.lazy(() => import("./OtherComponent"));

function MyComponent() {
  return (
    <div>
      <Suspense fallback={<div>Loading...</div>}>
        <OtherComponent />
      </Suspense>
    </div>
  );
}
```

- `Suspense`组件可以放在懒加载组件上任何位置，可以包裹多个 lazy 组件。
