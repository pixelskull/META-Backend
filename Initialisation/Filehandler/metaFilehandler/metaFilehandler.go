package metaFilehandler

import("os"
       "os/exec"
       "log")

// creates folder META in tempDir if not existing and returns the path
func PrepareTempFolder() string{
	tmpDir := os.TempDir()
	path 	 := tmpDir + "META"

	folder_exists, _ := Exists(path)
	if folder_exists == false {
		// create Folder and error handling
		err := os.Mkdir(path, os.ModePerm) // TODO: check if umask problem still exists in tmp folder
		if err != nil {
			log.Fatalf("MkdirAll failed %q: %s", path, err)
		}
	}
	// return Path
	return path
}

// performs compilation on file
func PerformFileAction(hash string, contents []byte) error {
	log.Println("started goroutine for sending file to kafka")

	ir_file := SaveIRFile(hash, contents)

	app := "/usr/local/bin/compilation.py"

	cmd := exec.Command(app, ir_file)
	stdout, err := cmd.Output()

	if err != nil {
		log.Fatalf("failed to execute command " + app + ": " + err.Error())
		return err
	}

	log.Printf(string(stdout))
	return nil
}

// exists returns whether the given file or directory exists or not
func Exists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil { return true, nil }
	if os.IsNotExist(err) { return false, nil }
	return true, err
}

// saves content array to LLVM-IR file with given name (<name>.ll)
func SaveIRFile(name string, contents []byte) string {
	// create file to contain contents with name (eg. hash)
	filePath := PrepareTempFolder() + name + ".ll" // "tmp/"  TODO: Change path to use folder if creation is done right
	f, err := os.Create(filePath)
	if err != nil {
		panic(err)
	}
	// close fo on exit and check for its returned error
	defer func() {
		if err := f.Close(); err != nil {
			panic(err)
		}
	}()
	// write contents
	if _, err := f.Write(contents); err != nil {
		panic(err)
	}
	log.Println("created file at Path: " + filePath)
	return filePath
}
