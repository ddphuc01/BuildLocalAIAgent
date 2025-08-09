import React, { useEffect, useRef, useState } from 'react'
import Editor from '../editor/Editor'
import Chat from '../ai/Chat'

export const App: React.FC = () => {
  const [backendUrl, setBackendUrl] = useState<string>('http://localhost:8000')

  useEffect(() => {
    const anyWindow: any = window
    if (anyWindow?.api?.backendUrl) {
      setBackendUrl(anyWindow.api.backendUrl)
    }
  }, [])

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 380px', height: '100vh' }}>
      <Editor />
      <Chat backendUrl={backendUrl} />
    </div>
  )
}

export default App


