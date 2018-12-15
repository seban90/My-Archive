
import cv2

"""
CAM class is made for just using opencv libraries 
very conveniently in Video processing by python
I will add more brenches to apply many kinds of filters to video image
One day, GUI could support you to controll this method
"""
class CAM:
    def __init__(self, rows=320, cols=240, windowname="test"):
        self.cam = cv2.VideoCapture(0)
        self.cam.set(3, rows)
        self.cam.set(4,cols)
        self.winName = windowname
    def run(self, appliedFilter=None):
        rel, img = self.cam.read()

        if appliedFilter == None:
            pass
        elif (appliedFilter == "CANNY") or (appliedFilter == "Canny") or (appliedFilter == "canny"):
            img = cv2.Canny(img, 30, 120)
        elif (appliedFilter == "GAUSSIAN") or (appliedFilter=="Gaussian") or (appliedFilter=="gaussian"):
            img = cv2.GaussianBlur(img, (5,5), 4)
        else:
            pass
        
        cv2.imshow(self.winName, img)
if __name__ == '__main__':
    
    c = CAM(640, 480, "cam set")
    status = True
    
    while status:
        c.run()    
        if cv2.waitKey(10) == 27:
            status = False
            cv2.destroyAllWindows()

    