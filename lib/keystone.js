'use babel';

import keystoneView from './keystone-view';
import { CompositeDisposable } from 'atom';

export default {

  keystoneView: null,
  modalPanel: null,
  subscriptions: null,
  ports: null,

  activate(state) {
    this.keystoneView = new keystoneView(state.keystoneViewState);

    var Elm = require('../build/keystone.js');
    var app = Elm.Keystone.embed(this.keystoneView.getElement());
    this.setupPorts(app.ports);

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

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'keystone:parse': () => this.parse()
    }));
  },

  setupPorts(ports) {
    this.ports = ports;
    this.ports.notify.subscribe((ntfn) => {
      console.log("Keystone: Notify request from Elm.", ntfn);
      let isErr = ntfn.isErr;
      let text = ntfn.text;
      if (isErr) {
        atom.notifications.addError("Error:", {"detail": text});
      } else {
        atom.notifications.addInfo("Info:", {"detail": text});
      }
    });
  },

  isMarkdown() {
    return atom.workspace.getActiveTextEditor().getPath().endsWith(".md");
  },

  parse() {
    let text = atom.workspace.getActiveTextEditor().getText();
    let isMarkdown = this.isMarkdown();
    console.log("Keystone: Parsing text. Is markdown?", isMarkdown);
    this.ports.parse.send([isMarkdown, text]);
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
