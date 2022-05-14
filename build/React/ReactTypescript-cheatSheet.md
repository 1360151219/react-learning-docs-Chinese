# React Typescript CheatSheets

文档也被部署到了另一个域名中 http://react.strk2.cn

## Typing Component Props

这节旨在让程序员对 typescript 有一个基本的方向认识和参考。

### 基本 Props 类型例子

```js
type AppProps = {
  message: string,
  count: number,
  disabled: boolean,
  /** array of a type! */
  names: string[],
  /** string literals to specify exact string values, with a union type to join them together */
  status: "waiting" | "success",
  /** any object as long as you dont use its properties (NOT COMMON but useful as placeholder) */
  obj: object,
  obj2: {}, // almost the same as `object`, exactly the same as `Object`
  /** an object with any number of properties (PREFERRED) */
  obj3: {
    id: string,
    title: string,
  },
  /** array of objects! (common) */
  objArr: {
    id: string,
    title: string,
  }[],
  /** a dict object with any number of properties of the same type */
  dict1: {
    [key: string]: MyTypeHere,
  },
  dict2: Record<string, MyTypeHere>, // equivalent to dict1
  /** any function as long as you don't invoke it (not recommended) */
  onSomething: Function,
  /** function that doesn't take or return anything (VERY COMMON) */
  onClick: () => void,
  /** function with named prop (VERY COMMON) */
  onChange: (id: number) => void,
  /** function type syntax that takes an event (VERY COMMON) */
  onChange: (event: React.ChangeEvent<HTMLInputElement>) => void,
  /** alternative function type syntax that takes an event (VERY COMMON) */
  onClick(event: React.MouseEvent<HTMLButtonElement>): void,
  /** an optional prop (VERY COMMON!) */
  optional?: OptionalType,
};
```

### 有用的 Props 类型例子

与接收其他 React 组件作为 props 的组件有关。

```js
export declare interface AppProps {
  children1: JSX.Element; // bad, doesnt account for arrays
  children2: JSX.Element | JSX.Element[]; // meh, doesn't accept strings
  children3: React.ReactChildren; // despite the name, not at all an appropriate type; it is a utility
  children4: React.ReactChild[]; // better, accepts array children
  children: React.ReactNode; // best, accepts everything (see edge case below)
  functionChildren: (name: string) => React.ReactNode; // recommended function as a child render prop type
  style?: React.CSSProperties; // to pass through style props
  onChange?: React.FormEventHandler<HTMLInputElement>; // form events! the generic parameter is the type of event.target
  //  more info: https://react-typescript-cheatsheet.netlify.app/docs/advanced/patterns_by_usecase/#wrappingmirroring
  props: Props & React.ComponentPropsWithoutRef<"button">; // to impersonate all the props of a button element and explicitly not forwarding its ref
  props2: Props & React.ComponentPropsWithRef<MyButtonWithForwardRef>; // to impersonate all the props of MyButtonForwardedRef and explicitly forwarding its ref
}
```

> 下面是一个`React.ReactNode`的边界例子

这个代码编译的时候没错但运行时报错:

```js
type Props = {
  children: React.ReactNode,
};

function Comp({ children }: Props) {
  return <div>{children}</div>;
}
function App() {
  return <Comp>{{}}</Comp>; // Runtime Error: Objects not valid as React Child!
}
```

This is because `ReactNode` includes `ReactFragment` which allows a `{}` type, which is **too wide**. Fixing this would break a lot of libraries, so for now you just have to be mindful that ReactNode is not absolutely bulletproof.

即`ReactNode`类型范围太过宽广，并不是刀枪不入的。

> `JSX.Element vs React.ReactNode`

A more technical explanation is that a valid React node is not the same thing as what is returned by React.createElement. Regardless of what a component ends up rendering, React.createElement always returns an object, which is the JSX.Element interface, but React.ReactNode is the set of all possible return values of a component.

- JSX.Element ->`React.createElement()`方法的返回值
- React.ReactNode -> 一个组件所有可能的返回值

## Function Components

下面例子是可以将它们写成接受 props 参数并返回一个 JSX 元素的普通函数。

```js
// Declaring type of props - see "Typing Component Props" for more examples
type AppProps = {
  message: string,
}; /* use `interface` if exporting so that consumers can extend */

// Easiest way to declare a Function Component; return type is inferred.可被推断的
const App = ({ message }: AppProps) => <div>{message}</div>;

// 推荐！！ you can choose annotate the return type so an error is raised if you accidentally return some other type
const App = ({ message }: AppProps): JSX.Element => <div>{message}</div>;

// you can also inline the type declaration; eliminates naming the prop types, but looks repetitive
const App = ({ message }: { message: string }) => <div>{message}</div>;
```

> 为什么`React.FC`令人失望？还有`React.FunctionComponent`/`React.VoidFunctionComponent`呢？

你可能会在很多基于 React+TypeScript 项目中看到以下代码：

```js
const App: React.FunctionComponent<{ message: string }> = ({ message }) => (
  <div>{message}</div>
);
```

然而现在有一个共识就是`React.FunctionComponent`（或者叫`React.FC`）令人失望。如果你同意这个观点并且想要 remove 掉它，可以使用[ this jscodeshift codemod](https://github.com/gndelia/codemod-replace-react-fc-typescript)

相比于普通的函数组件，`FC`有以下优势：

- `React.FunctionComponent` 是显式定义参数类型的，但普通组件函数是隐式定义返回类型的（需要加另外的 interface or type）。
- 它为像`displayName`、`propTypes`和`defaultProps`这样的静态属性提供类型检查和自动完成功能。
- 它提供了`children`的隐式定义。但更好的应该将`children`进行显式定义。

> 或者你可以使用`React.VFC`（`React.VoidFunctionComponent`），当需要显式定义`children`的时候。

简而言之，**就是`FC`内置的 props 已经定义了 children 的类型，而`VFC`并没有定义 children 类型**。下面给一个译者的一个例子：

```js
// good running
const Input: React.FunctionComponent<{
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void,
}> = ({ onChange, children }) => {
  return (
    <>
      {children}
      <input type="text" onChange={onChange} />
    </>
  );
};
// error: children is undefined
const Input: React.VoidFunctionComponent<{
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void,
}> = ({ onChange, children }) => {
  return (
    <>
      {children}
      <input type="text" onChange={onChange} />
    </>
  );
};
```

## Class Components

用到 typescript 之后，`React.Component<PropType, StateType>`是一个比较常用的类型，你可以为 props 和 state 定制类型。

```js
type MyProps = {
  // using `interface` is also ok
  message: string,
};
type MyState = {
  count: number, // like this
};
class App extends React.Component<MyProps, MyState> {
  state: MyState = {
    // optional second annotation for better type inference
    count: 0,
  };
  render() {
    return (
      <div>
        {this.props.message} {this.state.count}
      </div>
    );
  }
}
```

> 为什么注释了 state 类型两次。

第二次注释是为了让`this.setState()`正确的执行，因为这个方法来自于组件内部，但是初始化 state 的时候会覆盖基础实现所以你要确保告诉编译器说你并没有做任何类型上的变化。

> 不需要给 props 和 state 注释上`readonly`

这并不是必要的因为`React.Component<P,S>`内部已经将它们标记成不可改变的。

**Class Methods：**正常定义既可，但要记住函数参数需要被定义类型。

**Class Properties：**如果你需要定义类属性使用，像`state`一样定义即可。

```js
class App extends React.Component<{
  message: string,
}> {
  pointer: number; // like this
  componentDidMount() {
    this.pointer = 3;
  }
  render() {
    return (
      <div>
        {this.props.message} and {this.pointer}
      </div>
    );
  }
}
```

### getDerivedStateFromProps 的类型

下面举几个例子吧：

1. 已经定义过 State

```js
class Comp extends React.Component<Props, State> {
  static getDerivedStateFromProps(
    props: Props,
    state: State
  ): Partial<State> | null {
    //
  }
}
```

2. 尚未定义 State

```js
class Comp extends React.Component<
  Props,
  ReturnType<(typeof Comp)["getDerivedStateFromProps"]>
> {
  static getDerivedStateFromProps(props: Props) {}
}
```

3. 你希望 state 的类型来自于其他代码

```js
type CustomValue = any;
interface Props {
  propA: CustomValue;
}
interface DefinedState {
  otherStateField: string;
}
type State = DefinedState & ReturnType<typeof transformPropsToState>;
function transformPropsToState(props: Props) {
  return {
    savedPropA: props.propA, // save for memoization
    derivedState: props.propA,
  };
}
class Comp extends React.PureComponent<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      otherStateField: "123",
      ...transformPropsToState(props),
    };
  }
  static getDerivedStateFromProps(props: Props, state: State) {
    if (isEqual(props.propA, state.savedPropA)) return null;
    return transformPropsToState(props);
  }
}
```

## Hooks

### useState

对于一些简单的 value 来说，类型推断是能非常好的帮助到我们。

```js
const [val, toggle] = React.useState(false);
// `val` is inferred to be a boolean
// `toggle` only takes booleans
```

如果你想要依靠类型推断去使用比较复杂的类型，可以查看[使用类型推断](https://react-typescript-cheatsheet.netlify.app/docs/basic/troubleshooting/types/#using-inferred-types)章节

然而，很多 hooks 通常会被初始化一个空，你想知道如何去提供一个类型，就去明确声明类型，使用**联合类型**。

```ts
const [user, setUser] = React.useState<IUser | null>(null);

// later...
setUser(newUser);
```

你也可以使用类型断言。

```ts
const [user, setUser] = React.useState<IUser>({} as IUser);

// later...
setUser(newUser);
```

你应该在后面的代码中去为`user`设置 state，如果你不这样做，会引起运行时类型报错。

### useReducer

使用 typescript 来为 reducer 声明类型：

```ts
const initialState = { count: 0 };

type ACTIONTYPE =
  | { type: "increment"; payload: number }
  | { type: "decrement"; payload: string };

function reducer(state: typeof initialState, action: ACTIONTYPE) {
  switch (action.type) {
    case "increment":
      return { count: state.count + action.payload };
    case "decrement":
      return { count: state.count - Number(action.payload) };
    default:
      throw new Error();
  }
}

function Counter() {
  const [state, dispatch] = React.useReducer(reducer, initialState);
  return (
    <>
      Count: {state.count}
      <button onClick={() => dispatch({ type: "decrement", payload: "5" })}>
        -
      </button>
      <button onClick={() => dispatch({ type: "increment", payload: 5 })}>
        +
      </button>
    </>
  );
}
```

> 如果你使用`redux`,则有：redux 提供了一个方便的泛型`Reducer<State, Action>`
>
> ```ts
> import { Reducer } from 'redux';
>
> export function reducer: Reducer<AppState, Action>() {}
>
> ```

### useEffect / useLayoutEffect

这两者都会返回一个具有清理副作用功能的函数，这个函数如果没有返回值，根本就不需要类型。因此我们在使用的时候注意不要返回任何函数或者 undefined，我们看一下下面的一个例子：

```ts
function DelayedEffect(props: { timerMs: number }) {
  const { timerMs } = props;

  useEffect(
    () =>
      setTimeout(() => {
        /* do stuff */
      }, timerMs),
    [timerMs]
  );
  // bad example! setTimeout implicitly returns a number
  // because the arrow function body isn't wrapped in curly braces
  // 这里useEffect中返回了一个number，不符合
  return null;
}
```

### useRef

`useRef`返回一个要么只读要么可变的引用类型对象，这取决于你的类型参数是否完全覆盖住了初始值。

- **DOM Element Ref**

在需要使用`useRef`去获取 DOM 的引用的时候，我们通常给其初始值附上`null`，这种情况下就是只读的`.current`。我们需要给其声明类型：

```ts
function Foo() {
  // - If possible, prefer as specific as possible. For example, HTMLDivElement
  //   is better than HTMLElement and way better than Element.
  // - Technical-wise, this returns RefObject<HTMLDivElement>
  const divRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Note that ref.current may be null. This is expected, because you may
    // conditionally render the ref-ed element, or you may forgot to assign it
    if (!divRef.current) throw Error("divRef is not assigned");

    // Now divRef.current is sure to be HTMLDivElement
    doSomethingWith(divRef.current);
  });

  // Give the ref to an element so React can manage it for you
  return <div ref={divRef}>etc</div>;
}
```

如果你能确保`divRef.current`不会为 null，那你可以使用非空断言符号`!`

```ts
const divRef = useRef<HTMLDivElement>(null!);
// Later... No need to check if it is null
doSomethingWith(divRef.current);
```

但你如果没有将它与 Element 绑定起来，则报错。

- **Mutable value ref**

你也可以使用`useRef`来保存一个不会影响组件重新渲染的值。

```ts
function Foo() {
  // Technical-wise, this returns MutableRefObject<number | null>
  const intervalRef = useRef<number | null>(null);

  // You manage the ref yourself (that's why it's called MutableRefObject!)
  useEffect(() => {
    intervalRef.current = setInterval(...);
    return () => clearInterval(intervalRef.current);
  }, []);

  // The ref is not passed to any element's "ref" prop
  return <button onClick={/* clearInterval the ref */}>Cancel timer</button>;
}
```

### useImperativeHandle

> 这边资料太少，可以看一下[a discussion in our issues](https://github.com/typescript-cheatsheets/react/issues/106)

```ts
// 这个例子中并没有使用forwardRef
type ListProps<ItemType> = {
  items: ItemType[];
  innerRef?: React.Ref<{ scrollToItem(item: ItemType): void }>;
};

function List<ItemType>(props: ListProps<ItemType>) {
  useImperativeHandle(props.innerRef, () => ({
    scrollToItem() {},
  }));
  return null;
}
```

### Custom Hooks

如果你需要自定义 Hooks，你需要避免类型推断成一个联合类型数组。这里可以使用 const assertions

```ts
export function useLoading() {
  const [isLoading, setState] = React.useState(false);
  const load = (aPromise: Promise<any>) => {
    setState(true);
    return aPromise.finally(() => setState(false));
  };
  return [isLoading, load] as const; // infers [boolean, typeof load] instead of (boolean | typeof load)[]
}
```
