
import cv2

class CAM:
    def __init__(self, rows=320, cols=240, windowname="test"):
        self.cam = cv2.VideoCapture(0)
        self.cam.set(3, rows)
        self.cam.set(4,cols)
        self.winName = windowname
    def run(self):
        
        try:
            rel, img = self.cam.read()
            cv2.imshow(self.winName, img)
            if cv2.waitKey(10) == 27:
                cv2.distroyAllWindows()
                exit(0)
                
        except KeyboardInterrupt:
            exit(0)
            

if __name__ == '__main__':
    
    c = CAM(640, 480, "cam set")
    while True:
        c.run()