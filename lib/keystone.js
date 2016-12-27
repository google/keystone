'use babel';

/**
 * Copyright 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

    this.subscriptions = new CompositeDisposable();

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'keystone:renderDsm': () => {
        this.parse();
        this.displayDsm();
      }
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
