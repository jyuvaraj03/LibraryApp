import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"
import "tom-select/dist/css/tom-select.bootstrap5.min.css"
import _ from "lodash"
import {tomSelectLoad} from "../utils/tom_select";

// Connects to data-controller="searchable-select"
export default class extends Controller {
  static values = { url: String, filterParams: Object }

  connect() {
    new TomSelect(this.element, {
      valueField: 'id',
      searchField: ['text'],
      load: (query, callback) => tomSelectLoad(query, callback, this.filterParamsValue,
        this.urlValue, this.transformData)
    })
  }

  transformData(responseItems = {}) {
    return _.map(responseItems, (book) => {
      const name = _.get(book, 'name', '')
      const authorName = _.get(book, 'author.name', '')
      const id = _.get(book, 'id', '')
      const customNumber = _.get(book, 'custom_number', '')

      return {
        id: id,
        text: `#${customNumber} ${name} by ${authorName}`
      }
    })
  }
}
