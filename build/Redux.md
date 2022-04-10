# Redux 中文

## 介绍

Redux 是 JavaScript 应用程序的可预测状态容器。类似 Vuex 一样，Redux 也可以做到全局变量的一致性以及去监控全局变量的变化旅程。

你可以将 Redux 与 React 一起使用，或者与任何其他视图库一起使用。它很小(2kB，包括依赖项)，但有一个庞大的插件生态系统可用。

### 下载

#### Redux Toolkit

**Redux Toolkit**是我们官方推荐的编写 Redux 逻辑的方法。它包裹了 Redux 的核心，包含了我们认为构建 Redux 应用程序必不可少的包和函数。Redux Toolkit 构建在我们建议的最佳实践中，简化了大多数 Redux 任务，防止常见错误，并使编写 Redux 应用程序更容易。

```bash
# NPM

npm install @reduxjs/toolkit

# Yarn

yarn add @reduxjs/toolkit
```

#### Create a React Redux App

```bash
# Redux + Plain JS template
npx create-react-app my-app --template redux

# Redux + TypeScript template
npx create-react-app my-app --template redux-typescript
```

#### Redux core

```bash
# NPM
npm install redux

# Yarn
yarn add redux
```

#### 一个基本的例子

你的应用中的全局变量都被存储在了一个简单 store 里的一个树状对象中。改变这颗状态树的唯一办法就是去*create a action*（用来描述发生了什么），然后*dispatch*它到 store 中。

要指定状态如何更新以响应操作，可以编写纯 reducer 函数，根据旧状态和操作计算新状态。

> A reducer's function signature is: `(state, action) => newState`

```js
import { createStore } from "redux";

/**
 * This is a reducer - a function that takes a current state value and an
 * action object describing "what happened", and returns a new state value.
 * A reducer's function signature is: (state, action) => newState
 *
 * The Redux state should contain only plain JS objects, arrays, and primitives.
 * The root state value is usually an object. It's important that you should
 * not mutate the state object, but return a new object if the state changes. 即一定要返回一个新对象
 *
 * You can use any conditional logic you want in a reducer. In this example,
 * we use a switch statement, but it's not required.
 */
function counterReducer(state = { value: 0 }, action) {
  switch (action.type) {
    case "counter/incremented":
      return { value: state.value + 1 };
    case "counter/decremented":
      return { value: state.value - 1 };
    default:
      return state;
  }
}

// Create a Redux store holding the state of your app.
// Its API is { subscribe, dispatch, getState }.
let store = createStore(counterReducer);

// You can use subscribe() to update the UI in response to state changes.
// Normally you'd use a view binding library (e.g. React Redux) rather than subscribe() directly.
// There may be additional use cases where it's helpful to subscribe as well.

store.subscribe(() => console.log(store.getState()));

// The only way to mutate the internal state is to dispatch an action.
// The actions can be serialized, logged or stored and later replayed.
store.dispatch({ type: "counter/incremented" });
// {value: 1}
store.dispatch({ type: "counter/incremented" });
// {value: 2}
store.dispatch({ type: "counter/decremented" });
// {value: 1}
```

不是直接改变状态，而是指定希望对称为动作的普通对象发生的变化。然后编写一个称为 reducer 的特殊函数来决定每个操作如何转换整个应用程序的状态。

在一个典型的 Redux 应用程序中，只有一个具有单一根还原功能的单一 store。随着应用程序的增长，您将根 reducer 分解为独立运行在状态树的不同部分的更小的 reducer。这就像 React 应用中只有一个根组件，但它是由许多小组件组成的。

#### RTK 例子

Redux Toolkit 简化了编写 Redux 逻辑和设置存储的过程。在 Redux Toolkit 中，同样的逻辑看起来是这样的:

```js
import { createSlice, configureStore } from "@reduxjs/toolkit";

const counterSlice = createSlice({
  name: "counter",
  initialState: {
    value: 0,
  },
  reducers: {
    incremented: (state) => {
      // Redux Toolkit allows us to write "mutating" logic in reducers. It
      // doesn't actually mutate the state because it uses the Immer library,
      // which detects changes to a "draft state" and produces a brand new
      // immutable state based off those changes
      state.value += 1;
    },
    decremented: (state) => {
      state.value -= 1;
    },
  },
});

export const { incremented, decremented } = counterSlice.actions;

const store = configureStore({
  reducer: counterSlice.reducer,
});

// Can still subscribe to the store
store.subscribe(() => console.log(store.getState()));

// Still pass action objects to `dispatch`, but they're created for us
store.dispatch(incremented());
// {value: 1}
store.dispatch(incremented());
// {value: 2}
store.dispatch(decremented());
// {value: 1}
```

## 基本概念和 API

> 参考自阮一峰老师的博客

### Store

Store 就是一个全局状态存储的容器。整个 App 只能有一个 Store

Redux 提供 createStore 这个函数，用来生成 Store。

`createStore(reducer, [preloadedState], [enhancer])`

- reducer (Function): 一个 reducer 用于返回一个新的 state，它接收当前 state 以及一个 action
- [preloadedstate]: 初始化state状态
- [enhancer]：用于引用第三方库来增强 store

```js
import { createStore } from "redux";
const store = createStore(fn);
```

注意：

- 与 store 相反可以使用`combineReducers`来创建多个小 reducer
- Redux State 通常是 plain JS 对象和数组。
- 如果你的 State 是一个普通的对象或者数组，永远不要去改变它。更新的时候需要返回一个全新的对象

### State

Store 对象存储所有的数据，如果要获得某个时间点上的数据快照，即 State，可以使用`store.getState()`来获取

```js
import { createStore } from "redux";
const store = createStore(fn);

const state = store.getState();
```

Redux 规定， 一个 State 对应一个 View。只要 State 相同，View 就相同。你知道 State，就知道 View 是什么样，反之亦然。

### Action

用户无法直接操作 State，必须经过 Action 来改变 State

Action 是一个对象，`type`属性必须：

```js
const action = {
  type: "ADD_TODO",
  payload: "Learn Redux",
};
```

### Dispatch

`store.dispatch(action)`是去发起一个 action 来改变 state 的唯一办法

```js
import { createStore } from "redux";
const store = createStore(fn);

store.dispatch({
  type: "ADD_TODO",
  payload: "Learn Redux",
});
```

#### Reducer

Store 收到 Action 后必须要返回一个新对象，这样 state 才会更新。这种 State 计算过程就叫做 Reducer

```js
const defaultState = 0;
const reducer = (state = defaultState, action) => {
  switch (action.type) {
    case "ADD":
      return state + action.payload;
    default:
      return state;
  }
};

const state = reducer(1, {
  type: "ADD",
  payload: 2,
});
```

实际上 Reducer 函数不用这样手动调用，因为`store.dispatch`方法会触发 Reducer 的自动执行。为此我们在`createStore(reducer)`传一个 reducer 进去，让 Store 知道更新的时候要去调用这个 Reducer 即可。

> 注意，`Reducer`是一个纯函数，同样的 State 必然会返回同样的一个对象。但也正因为这一点，Reducer 函数里面不能改变 State，必须返回一个全新的对象。

这里给一个简单的案例：

```js
const Counter = ({ value, onIncrement, onDecrement }) => (
  <div>
    <h1>{value}</h1>
    <button onClick={onIncrement}>+</button>
    <button onClick={onDecrement}>-</button>
  </div>
);

const reducer = (state = 0, action) => {
  switch (action.type) {
    case "INCREMENT":
      return state + 1;
    case "DECREMENT":
      return state - 1;
    default:
      return state;
  }
};

const store = createStore(reducer);

const render = () => {
  ReactDOM.render(
    <Counter
      value={store.getState()}
      onIncrement={() => store.dispatch({ type: "INCREMENT" })}
      onDecrement={() => store.dispatch({ type: "DECREMENT" })}
    />,
    document.getElementById("root")
  );
};

render();
store.subscribe(render);
```
