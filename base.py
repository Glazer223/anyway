from models import *

def get_user():
    pass

def user_optional(handler):
    def check_login(self, *args, **kwargs):
        self.user = get_user()
        return handler(self, *args, **kwargs)

    return check_login

def user_required(handler):
    def check_login(self, *args, **kwargs):
        user = get_user()
        if not user:
            self.session["last_page_before_login"] = self.request.path + "?" + self.request.query_string
            self.redirect("/")
        else:
            self.user = user
            return handler(self, *args, **kwargs)

    return check_login


