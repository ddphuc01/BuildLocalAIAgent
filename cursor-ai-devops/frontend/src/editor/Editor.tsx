import React, { useEffect, useRef } from 'react'
import * as monaco from 'monaco-editor'

const Editor: React.FC = () => {
  const ref = useRef<HTMLDivElement | null>(null)
  const editorRef = useRef<monaco.editor.IStandaloneCodeEditor | null>(null)

  useEffect(() => {
    if (ref.current) {
      editorRef.current = monaco.editor.create(ref.current, {
        language: 'yaml',
        theme: 'vs-dark',
        value: '# Start coding DevOps configs here\n',
        automaticLayout: true
      })
    }
    return () => editorRef.current?.dispose()
  }, [])

  return <div ref={ref} style={{ width: '100%', height: '100%' }} />
}

export default Editor


