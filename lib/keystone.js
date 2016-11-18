'use babel';

import keystoneView from './keystone-view';
import { CompositeDisposable } from 'atom';

export default {

  keystoneView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.keystoneView = new keystoneView(state.keystoneViewState);

    var Elm = require('../build/keystone.js');
    var app = Elm.Keystone.embed(this.keystoneView.getElement());
    // setupPorts(app.ports)

    this.modalPanel = atom.workspace.addModalPanel({
      item: this.keystoneView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'keystone:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.keystoneView.destroy();
  },

  serialize() {
    return {
      keystoneViewState: this.keystoneView.serialize()
    };
  },

  toggle() {
    console.log('keystone was toggled!');
    return (
      this.modalPanel.isVisible() ?
      this.modalPanel.hide() :
      this.modalPanel.show()
    );
  }

};
