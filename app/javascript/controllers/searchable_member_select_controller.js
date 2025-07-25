import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"
import _ from "lodash"
import {tomSelectLoad} from "../utils/tom_select";
import {fetchJson} from "../utils/fetch_utils";

// Connects to data-controller="searchable-member-select"
export default class extends Controller {
  static values = { url: String, filterParams: Object, initialItem: String }

  // TODO: DRY this controller. Duplicated from searchable_book_select_controller
  async connect() {
    const initialOptions = this.initialItemValue ? await fetchJson(this.urlValue, { params: { search: this.initialItemValue } }).then(this.transformData) : [];
    const initialItem = _.get(initialOptions, '0.id');
    new TomSelect(this.element, {
      valueField: 'id',
      searchField: ['text'],
      items: [initialItem],
      options: initialOptions,
      load: (query, callback) => tomSelectLoad(query, callback, this.filterParamsValue,
                                                                    this.urlValue, this.transformData)
    })
  }

  transformData(responseItems = {}) {
    return _.map(responseItems, (member) => {
      const id = _.get(member, 'id', '')
      const customNumber = _.get(member, 'custom_number', '')
      const personalNumber = _.get(member, 'personal_number', '')
      const name = _.get(member, 'name', '')

      return {
        id: id,
        text: `${customNumber} | ${personalNumber} - ${name}`
      }
    })
  }
}
