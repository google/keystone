'use babel';

import keystoneView from './keystone-view';
import { CompositeDisposable } from 'atom';

export default {

  keystoneView: null,
  subscriptions: null,
  ports: null,

  activate(state) {
    this.keystoneView = new keystoneView(state.keystoneViewState);

    var Elm = require('../build/keystone.js');
    var app = Elm.Keystone.embed(this.keystoneView.getElement());
    this.setupPorts(app.ports);

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'keystone:renderDsm': () => this.displayDsm()
    }));

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'keystone:parse': () => this.parse()
    }));

    atom.workspace.addOpener((uriToOpen) => {
      [protocol, path] = uriToOpen.split('://');
      if (protocol !== 'keystone') {
        console.error("Keystone: Unrecognized protocol", protocol);
        return;
      }

      try {
        path = decodeURI(path);
      } catch (e) {
        return;
      }

      if (path.startsWith('editor/')) {
        return this.createDsmView(path.substring(7));
      } else {
        console.error("Keystone: Unrecognized path", path);
      }
    });
    console.log("Keystone: Activated");
  },

  setupPorts(ports) {
    this.ports = ports;
    this.ports.notify.subscribe((ntfn) => {
      console.log("Keystone: Notify request from Elm.", ntfn);
      let isErr = ntfn.isErr;
      let isSuccess = ntfn.isSuccess;
      let text = ntfn.text;
      if (isErr) {
        atom.notifications.addError("Error:", {"detail": text});
      } else if (isSuccess) {
        atom.notifications.addSuccess("Success!", {"detail": text});
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
    this.subscriptions.dispose();
    this.keystoneView.destroy();
    console.log("Keystone: Deactivated");
  },

  serialize() {
    return {
      keystoneViewState: this.keystoneView.serialize()
    };
  },

  uriForEditor(editor) {
    return "keystone://editor/" + editor.id;
  },

  createDsmView(editorId) {
    return this.keystoneView;
  },

  displayDsm() {
    let editor = atom.workspace.getActiveTextEditor();
    if (editor) {
      let uri = this.uriForEditor(editor);
      let previousActivePane = atom.workspace.getActivePane();
      let options = { searchAllPanes: true };
      atom.workspace.open(uri, options);

      console.log('Keystone: Displaying DSM view for', uri);
    } else {
      console.log('Keystone: DSM view already displayed');
    }
  }
};
