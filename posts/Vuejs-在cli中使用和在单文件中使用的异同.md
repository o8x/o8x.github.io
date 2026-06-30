---
display-name: Vuejs 在cli中使用和在单文件中使用的异同
date: 2018-07-27 09:24:09
tags:

- Vue

---

# 前言

> 通常我们是这样使用vue的：`vue init webpack name`   
> 可以使用多种组件和各种npm包 ，实在是很舒服    
> 但是有时候我们只需要在某个页面中使用vue，而不是整个项目    
> 还有些情况是，在某个系统给内部使用vue，如果使用cli建立整个项目的话 ，就需要单独给vue开放授权或者开发接口。这并不是我们想要的效果。    
> 所以就有了第二种办法，在页面中通过cdn或者文件引入编译好的vuejs文件 ，把vue当作angularjs类似的框架来使用     
> 本节主要讲述单文件和cli的异同

--------------------------------

# 单文件引入的缺点

- 如果使用es6语法 ，无法保证浏览器兼容性
- 不能使用vue的大部分npm生态。
- 代码组织结构不明确 ，必须在一个文件中组织一切。
- 运行时编译，效率堪忧
- 无法使用nodejs带来的便利
- 代码直接写在js中，暴露了源码

> 废话不多说，下面上代码

----------------------------

# Code

## 单文件方式

```javascript
<script src="https://cdn.bootcss.com/vue/2.5.15/vue.min.js"></script>
<script src="https://cdn.bootcss.com/axios/0.18.0/axios.min.js"></script>
<div id="app" valign="top">
    <a class="btn btn-primary"
    @click="save()">保存
</a>
</div>
<script>
    new Vue({
    el: '#app',
    data: {
    code: '',
    options: [
    // 
    ]
},
    mounted() {
    console.log('vue mounted succcess');
},
    methods: {
    save() {
    axios.post('/api/getUserInfo/12' ,{})
}
}
});
</script>
```

## cli方式

```javascript
<template>
    <div class="container">
        //
    </div>
</template>
<script>
    // import 各种生态
    export default {
    name: 'HelloWorld',
    data() {
    return {
    code: '',
    options: [
    //
    ]
}
},
    mounted() {
    console.log('vue mounted succcess');
},
    methods: {
    save() {
    axios.post('/api/getUserInfo/12' ,{}})
}
}
    }
</script>
```

> 有没有很像

# END
