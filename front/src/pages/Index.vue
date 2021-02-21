<template>
  <q-page>
    <q-input
        v-model="url"
        type="url"
        hint="URL"
    />
    <q-btn
        color="white"
        text-color="black"
        label="Récupérer le contenu"
        @click="onClick"
    />
    <q-btn
        color="white"
        text-color="black"
        label="Vider"
        @click="onReset"
    />
    {{ data.length }} liens
    <q-table
      title="web crawler"
      :data="data"
      :columns="columns"
      row-key="url"
      dense
      :rows-per-page-options="[0]"
      :pagination.sync="pagination"
    >
      <template
        v-slot:body="props"
      >
        <q-tr :props="props">
          <q-td
            key="url"
            :props="props"
          >
            {{ props.row.url }}
          </q-td>
          <q-td
            key="state"
            :props="props"
          >
            {{ props.row.state }}
          </q-td>
        </q-tr>
      </template>

    </q-table>
  </q-page>
</template>

<script>
export default {
  name: 'PageIndex',
  data () {
    return {
      columns: [
        {
          label: 'url',
          sortable: false,
          field: 'url',
          align: 'left',
          name: 'url'
        },
        {
          label: 'state',
          sortable: false,
          field: 'state',
          align: 'left',
          name: 'state'
        }
      ],
      pagination: {
        page: 1,
        rowsPerPage: 0 // 0 means all rows
      },
      url: 'http://www.google.fr',
      back: 'http://back-webcrawler.traefik.me/',
      data: [],
      launch: 0
    }
  },
  mounted () {
  },
  methods: {
    onReset () {
      this.data = []
      this.launch = 0
    },
    onClick () {
      this.launch = 1
      this.getData(this.url)
    },
    continuer () {
      if (this.launch === 0) {
        this.data = []
        this.launch = 0
        return
      }
      let trouver = 0
      this.data.forEach(
        element => {
          if (element.state === 0 && trouver === 0) {
            trouver = 1
            this.getData(element.url)
          }
        }
      )
    },
    getData (url) {
      if (this.launch === 0) {
        this.data = []
        this.launch = 0
        return
      }
      this.$axios.get(
        this.back,
        {
          params: {
            url
          }
        }
      ).then(json => {
        if (this.launch === 0) {
          this.data = []
          this.launch = 0
          return
        }
        const url = json.data.url
        let trouver = 0
        this.data.forEach(
          links => {
            if (links.url === url) {
              trouver = 1
              links.state = 1
            }
          }
        )
        if (trouver === 0) {
          this.data.push({
            url: url,
            state: 1
          })
        }
        json.data.links.forEach(
          url => {
            let trouver = 0
            this.data.forEach(
              links => {
                if (links.url === url) {
                  trouver = 1
                }
              }
            )
            if (trouver === 0) {
              this.data.push({
                url: url,
                state: 0
              })
            }
          }
        )
        if (this.launch === 0) {
          this.data = []
          this.launch = 0
          return
        }
        this.continuer()
      })
    }
  }
}
</script>
