import Vue from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify';
import VueRouter from 'vue-router'

import Login from './pages/Login'
import FirstFamily from './pages/FirstFamily'
import Family from './pages/Family'
import Avatar from './pages/Avatar'
import store from './store'

Vue.config.productionTip = false
Vue.use(VueRouter)

const router = new VueRouter({
  routes: [
    // dynamic segments start with a colon
    { path: '/login', component: Login },
    { path: '/first_family', component: FirstFamily },
    { path: '/family', component: Family },
    { path: '/avatar', component: Avatar }
  ],
  mode: 'history'
})

new Vue({
  vuetify,
  router,
  store,
  render: h => h(App)
}).$mount('#app')


// Initialize ethers store
store.dispatch('ethers/init')
