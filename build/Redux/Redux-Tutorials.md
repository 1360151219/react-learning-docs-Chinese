# Redux Tutorial

Quick Start 简单的介绍了一下以 `Redux Toolkit + React application`为技术栈的应用, TypeScript Quick Start 则介绍了如何加上 TypeScript 进行应用搭建。

We have two different full-size tutorials:

- The Redux Essentials tutorial is a "top-down" tutorial that teaches "how to use Redux the right way", using our latest recommended APIs and best practices.

- The Redux Fundamentals tutorial is a "bottom-up" tutorial that teaches "how Redux works" from first principles and without any abstractions, and why standard Redux usage patterns exist.

> We recommend starting with the Redux Essentials tutorial, since it covers the key points you need to know about how to get started using Redux to write actual applications.

## Redux Toolkit Quick Start

> 本文主要使用`React Toolkit`以及`React-Redux`来搭建一个 Store

### 下载

```bash
npm install @reduxjs/toolkit react-redux
```

### 创建一个 Redux Store

我们可以创建一个全局 Store，路径是`src/store/index.js`：

```js
// app/store.js
import { configureStore } from "@reduxjs/toolkit";
export default configureStore({
  reducer: {},
});
```

这里相比 Redux 而言，已经自动配置好了 Redux Devtools 以便于帮助你在开发的时候去查看 store 的状态

### 将 Store 连接到你的 App 上

一旦全局 Store 被创建好了，我们就可以使用*a React-Redux* `<Provider>` 来将 App 包裹起来从而注入到 App 中。

```js
import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import store from "./app/store";
import { Provider } from "react-redux";

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById("root")
);
```

### 创建一个 Redux 状态切片

我们创建一个新文件，在其中从 Redux Toolkit 引进`createSlice` API。

创建一个状态切片需要一个字符串名字`name`、一个初始化`state`以及一个或多个`reducer`来定义状态如何去更新。

Redux 要求我们保持状态的不变性。即对象的完全更换而不是保持堆地址不变。然而 Redux Toolkit 的`createSlice` and `createReducer` API 内部引入了`Immer`库来保证我们编写“突变”更新逻辑，使其成为正确的不可变更新。

```js
import { createSlice } from "@reduxjs/toolkit";

export const counterSlice = createSlice({
  name: "counter",
  initialState: {
    value: 0,
  },
  reducers: {
    increment: (state) => {
      // Redux Toolkit allows us to write "mutating" logic in reducers. It
      // doesn't actually mutate the state because it uses the Immer library,
      // which detects changes to a "draft state" and produces a brand new
      // immutable state based off those changes
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    incrementByAmount: (state, action) => {
      state.value += action.payload;
    },
  },
});

// Action creators are generated for each case reducer function
export const { increment, decrement, incrementByAmount } = counterSlice.actions;
// createSlice 会根据据你传入的reducers自动生成正确的actions和reducer
export default counterSlice.reducer;
```

### 将切片 Reducers 加入到全局 Store 中

在`configureStore.reducer`中传入你想要加入的切片 Reducers

```js
import { configureStore } from "@reduxjs/toolkit";
import counterReducer from "../features/counter/counterSlice";

export default configureStore({
  reducer: {
    counter: counterReducer,
  },
});
```

### 在 React 组件中去使用 Redux State and Actions

现在我们可以使用 React-Redux hooks 来让 Store 和组件交互起来啦。

我们通过`useSelector`来获取 State，`useDispatch`来推送 actions

```js
import React from "react";
import { useSelector, useDispatch } from "react-redux";
import { decrement, increment } from "./counterSlice";
import styles from "./Counter.module.css";

export function Counter() {
  const count = useSelector((state) => state.counter.value);
  const dispatch = useDispatch();
  return (
    <div>
      <div>
        <button
          aria-label="Increment value"
          onClick={() => dispatch(increment())}
        >
          Increment
        </button>
        <span>{count}</span>
        <button
          aria-label="Decrement value"
          onClick={() => dispatch(decrement())}
        >
          Decrement
        </button>
      </div>
    </div>
  );
}
```

现在，你随时可以点击"Increment" and "Decrement" 按钮：

- 相应的 Redux action 会被推送到 Store 中去
- 然后经过 Reducer，根据 actions type 来执行对应的更新 State 操作
- 最后 React 组件可以从 Store 得到最新的 State 并且重新渲染组件

### 你学到了什么

That was a brief overview of how to set up and use Redux Toolkit with React. Recapping the details:

> **SUMMARY**
>
> - **创建一个全局 Store** `configureStore`
>   - `configureStore` accepts a `reducer` function as a named argument
>   - `configureStore` automatically sets up the store with good default
>     settings
> - **给 App 注入全局 Store**
>   - Put a React-Redux `<Provider>` component around your `<App />`
>   - Pass the Redux store as `<Provider store={store}>`
> - **创建一个状态切片 `createSlice`**
>   - Call createSlice with a string `name`, an initial `state`, and named `reducer functions`
>   - Reducer functions may "mutate" the state using `Immer`
>   - Export the generated slice reducer and action creators
> - **在你的 React 组件中使用 React-Redux `useSelector/useDispatch` hooks**
>   - Read data from the store with the `useSelector` hook
>   - Get the dispatch function with the `useDispatch` hook, and dispatch actions as needed

### 一个完整的计数 App 例子

感兴趣的同学可以直接去 [官方文档](https://redux.js.org/tutorials/quick-start) 查看，下面只截取核心代码

`counterSlice.js`:

```js
import { createSlice } from "@reduxjs/toolkit";

export const counterSlice = createSlice({
  name: "counter",
  initialState: {
    value: 0,
  },
  reducers: {
    increment: (state) => {
      // Redux Toolkit allows us to write "mutating" logic in reducers. It
      // doesn't actually mutate the state because it uses the immer library,
      // which detects changes to a "draft state" and produces a brand new
      // immutable state based off those changes
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    incrementByAmount: (state, action) => {
      state.value += action.payload;
    },
  },
});

export const { increment, decrement, incrementByAmount } = counterSlice.actions;

// The function below is called a thunk and allows us to perform async logic. It
// can be dispatched like a regular action: `dispatch(incrementAsync(10))`. This
// will call the thunk with the `dispatch` function as the first argument. Async
// code can then be executed and other actions can be dispatched
export const incrementAsync = (amount) => (dispatch) => {
  setTimeout(() => {
    dispatch(incrementByAmount(amount));
  }, 1000);
};

// The function below is called a selector and allows us to select a value from
// the state. Selectors can also be defined inline where they're used instead of
// in the slice file. For example: `useSelector((state) => state.counter.value)`
export const selectCount = (state) => state.counter.value;

export default counterSlice.reducer;
```

`Counter.js`:

```js
import React, { useState } from "react";
import { useSelector, useDispatch } from "react-redux";
import {
  decrement,
  increment,
  incrementByAmount,
  incrementAsync,
  selectCount,
} from "./counterSlice";
import styles from "./Counter.module.css";

export function Counter() {
  const count = useSelector(selectCount);
  const dispatch = useDispatch();
  const [incrementAmount, setIncrementAmount] = useState("2");

  return (
    <div>
      <div className={styles.row}>
        <button
          className={styles.button}
          aria-label="Increment value"
          onClick={() => dispatch(increment())}
        >
          +
        </button>
        <span className={styles.value}>{count}</span>
        <button
          className={styles.button}
          aria-label="Decrement value"
          onClick={() => dispatch(decrement())}
        >
          -
        </button>
      </div>
      <div className={styles.row}>
        <input
          className={styles.textbox}
          aria-label="Set increment amount"
          value={incrementAmount}
          onChange={(e) => setIncrementAmount(e.target.value)}
        />
        <button
          className={styles.button}
          onClick={() =>
            dispatch(incrementByAmount(Number(incrementAmount) || 0))
          }
        >
          Add Amount
        </button>
        <button
          className={styles.asyncButton}
          onClick={() => dispatch(incrementAsync(Number(incrementAmount) || 0))}
        >
          Add Async
        </button>
      </div>
    </div>
  );
}
```

## Redux Toolkit TypeScript Quick Start

> 想要更具体的了解细节可以关注 https://redux.js.org/usage/usage-with-typescript

### 介绍

本文主要关注在如何建立 TypeScript 为主的 Redux+React 应用。

Redux Toolkit 是基于 TypeScript 编写的，因此 TS 类型定义也包含在其中。React Redux 也有它自身的类型定义`@types/react-redux`。在 React Redux v7.2.3 中，`@types/react-redux`会自动地和源库一起被安装下来。

> The **Redux+TS template for Create-React-App** comes with a working example of these patterns already configured.

---

### 定义根 State 和 Dispatch 类型

Redux Toolkit 的`configureStore` API 不需要用户去添加 types，但是，你可能需要去提取`RootState`和`Dispatch`的类型以便于被使用。而且从 Store 中去提取这些类型，有利于在用户添加更多的中间件或者状态切片的时候能够正确的更新。

```ts
import { configureStore } from "@reduxjs/toolkit";
// ...

const store = configureStore({
  reducer: {
    posts: postsReducer,
    comments: commentsReducer,
    users: usersReducer,
  },
});
// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof store.getState>;
// Inferred type: {posts: PostsState, comments: CommentsState, users: UsersState}
export type AppDispatch = typeof store.dispatch;
```

> 从这里也可以看出，`store.getState` API 是一个函数返回一个 State；

### 定义 Hooks 的类型

现在我们可以引用`RootState`和`AppDispatch` types 到每一个组件中去了，这可以更好的去创建类型化的`useDispatch`和`useSelector` hooks。下面是这样做的一些原因：

- 对于`useSelector`，它节省了你每次都要规定`(state: RootState)`的时间。
- 对于`useDispatch`，默认的`Dispatch`类型没有定义 thunks。为了去正确的 dispatch thunks，你需要使用特殊指定的`AppDispatch`类型，因为它包含了 thunk 中间件类型。因此一个被预先定义了类型的`useDispacth`hooks 使得你不需要再去引用`AppDispatch`了。

```js
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux'
import type { RootState, AppDispatch } from './store'

// Use throughout your app instead of plain `useDispatch` and `useSelector`
export const useAppDispatch = () => useDispatch<AppDispatch>()
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector
```

### 定义状态切片和 Action 的类型

每一个切片文件都应该去为它的初始 state 定义类型，这样`createSlice`才可以正确的推论出每一个 reducer 的 state 的类型

所有生成的 Actions 都应该使用 Redux Toolkit 中的`PayloadAction<T>`来定义类型。`PayloadAction<T>`可以对`action.payload`字段定义通用的类型参数

```ts
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import type { RootState } from "../../app/store";

// Define a type for the slice state
interface CounterState {
  value: number;
}

// Define the initial state using that type
const initialState: CounterState = {
  value: 0,
};

export const counterSlice = createSlice({
  name: "counter",
  // `createSlice` will infer the state type from the `initialState` argument
  initialState,
  reducers: {
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    // Use the PayloadAction type to declare the contents of `action.payload`
    incrementByAmount: (state, action: PayloadAction<number>) => {
      state.value += action.payload;
    },
  },
});

export const { increment, decrement, incrementByAmount } = counterSlice.actions;

// Other code such as selectors can use the imported `RootState` type
export const selectCount = (state: RootState) => state.counter.value;

export default counterSlice.reducer;
```

这里自动生成的 action creators 将会正确的将参数`payload`规定类型。

### 使用你的 Typed Hooks 吧

```tsx
import React from "react";

import { useAppSelector, useAppDispatch } from "app/hooks";

import { decrement, increment } from "./counterSlice";

export function Counter() {
  // The `state` arg is correctly typed as `RootState` already
  const count = useAppSelector((state) => state.counter.value);
  const dispatch = useAppDispatch();

  // omit rendering logic
}
```
