---
display-name: 现代浏览器客户端数据持久化方案 indexedDB
date: 2019-03-15 11:01:18
---

## IndexedDB 操作类

```js
/**
 * @method Promise createStore()
 * @method Promise save({data:data} ,[primary])
 * @method Promise get()
 * @method Promise find(primary)
 * @method Promise update({data:data} ,primary)
 * @method Promise destroy(paimary)
 * @method Promise clear()
 *
 * @example
 *  　let db = new DB()
 *    db.setVersion(版本 ,默认为2)
 *    db.setPrimaryKey('主键名')
 *    db.setStore('存储库名')
 *    db.setDatabase('数据库名')
 *    // 链接存储库
 *    await db.createStore()
 *    // 添加或更新数据
 *    await db.save({data:data} ,[primary])
 *    // 获取全部数据
 *    await db.get()
 *    // 获取一条数据
 *    await db.find(primary)
 *    // 依据主键更新
 *    await db.update({data:data} ,primary)
 *    // 依据主键删除
 *    await db.destroy(paimary)
 *    // 清空全表
 *    await db.clear()
 * @constructor
 */
function DB() {
    // 实例
    this.version = 2
    this.database = null
    this.table = null
    this.primaryKey = 'key'

    // 创建数据库和存储空间(表)
    this.createStore = async (store = null) => {
        if (store !== null) {
            this.setStore(store)
        }

        if (this.supportIndexDB()) {
            throw new Error('浏览器不支持 IndexDB 请更换浏览器')
        }

        // 连接数据库
        let conn = indexedDB.open(this.database, this.version)
        conn.onerror = event => {
            throw new Error('不能打开数据库 CODE: ' + event.target.errorCode)
        }

        conn.onupgradeneeded = event => {
            this.instance = event.target.result
            // 存在则删除
            if (this.instance.objectStoreNames.contains(this.table)) {
                this.instance.deleteObjectStore(this.table)
            }

            // 创建表
            this.instance.createObjectStore(this.table, {keyPath: this.primaryKey})
        }

        // 返回资源
        return new Promise((resolve, reject) => conn.onsuccess = event => {
            this.instance = event.target.result
            resolve(this.instance)
        })
    }

    /**
     * 获取所有值
     * @returns {Promise<any>}
     */
    this.get = async () => {
        let request = this.getTransaction().getAll()
        return new Promise((resolve, reject) => request.onsuccess = () => resolve(request.result))
    }

    /**
     * 根据主键查找
     * @param primary
     * @returns {Promise<any>}
     */
    this.find = async primary => {
        if (!primary) {
            throw new Error('主键不能为空')
        }

        let request = this.getTransaction().get(primary)
        return new Promise((resolve, reject) => request.onsuccess = () => resolve(request.result))
    }

    /**
     * 插入或更新数据
     * @param data
     * @param primary
     */
    this.save = (data, primary) => {
        //　如果数据中的第一级含有名为keyPath的key , 那么就不能通过第二个参数指定 key , 即使 key = primary
        // 例如　{id:1,app:[],b:12} ,那么1就会被自动设为主键，无法再使用primary指定，但是更新可以
        let request
        // 如果存在不存在ID , 那么就使用指定的主键创建数据，存在就用默认主键
        if (typeof data[this.primaryKey] === 'undefined') {
            if (typeof primary === 'undefined') {
                throw new Error('数据不包含默认主键，且没有显式声明主键')
            }
            request = this.getTransaction().add(data)
        } else {
            request = this.getTransaction().add(data, primary)
        }

        return new Promise((resolve, reject) => {
            request.onsuccess = () => {
                resolve(request.result)
            }
            request.onerror = () => {
                resolve(this.update(data, primary))
            }
        })
    }

    /**
     * 依据主键更新数据
     * @param data
     * @param primary
     */
    this.update = async (data, primary) => {
        //此处须显式声明事物
        let request = this.getTransaction().put(data, primary)
        return new Promise((resolve, reject) => {
            request.onsuccess = () => {
                resolve(request.result)
            }
            request.onerror = () => {
                reject(event.target.error.code, event.target.error.message)
            }
        })
    }

    /**
     * 根据主键删除
     * @param primary
     * @returns {Promise<any>}
     */
    this.destroy = async primary => {
        let request = this.getTransaction().delete(primary)
        return new Promise((resolve, reject) => request.onsuccess = e => resolve(e.target))
    }

    /**
     * 清空全表
     * @returns {Promise<any>}
     */
    this.clear = async () => {
        let request = this.getTransaction().clear()
        return new Promise((resolve, reject) => request.onsuccess = () => resolve(request))
    }

    /**
     * 获取一个事务
     * @returns {IDBObjectStore}
     */
    this.getTransaction = () => {
        return this.instance.transaction(this.table, 'readwrite').objectStore(this.table)
    }

    /**
     * 删除数据库
     * @returns {Promise<any>}
     */
    this.deleteDatabase = () => {
        let deleted = window.indexedDB.deleteDatabase(this.database)
        return new Promise((resolve, reject) => deleted.onsuccess = () => resolve('Database deleted successfully'))
    }

    /**
     * 判断是否支持IndexDB
     * @returns {boolean}
     */
    this.supportIndexDB = () => {
        return !window.indexedDB
    }

    this.closeDB = () => {
        this.instance.close()
        return this
    }

    this.setDatabase = db => {
        this.database = db
        return this
    }

    this.setStore = table => {
        this.table = table
        return this
    }

    this.setPrimaryKey = primaryKey => {
        this.primaryKey = primaryKey
        return this
    }

    this.setVersion = version => {
        this.version = version
        return this
    }
}
```
