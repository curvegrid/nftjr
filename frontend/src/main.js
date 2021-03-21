import Vue from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify';
import VueRouter from 'vue-router'

import Login from './pages/Login'
import store from './store'

Vue.config.productionTip = false
Vue.use(VueRouter)

const router = new VueRouter({
  routes: [
    // dynamic segments start with a colon
    { path: '/login', component: Login }
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
